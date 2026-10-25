"""Read typed S3A files, validate, stage with Spark JDBC, then publish one table atomically."""
import argparse
from functools import reduce
import os
import uuid

import psycopg
from psycopg import sql
from pyspark import StorageLevel
from pyspark.sql import SparkSession, functions as F, types as T
from settings import MODEL, LAYOUTS, required, selected_tables, s3_key


def spark_schema(table):
    types = {'bigint': T.LongType(), 'int': T.IntegerType(), 'text': T.StringType(),
             'date': T.DateType(), 'decimal': T.DecimalType(18, 2), 'boolean': T.BooleanType()}
    return T.StructType([T.StructField(c.name, types[c.kind], True) for c in MODEL['tables'][table]])


def session():
    # This tutorial pins PySpark 3.5.8, whose Hadoop client is 3.3.4.
    spark = (SparkSession.builder.master('local[2]').appName('Banking Floci to PostgreSQL')
             .config('spark.jars.packages', 'org.apache.hadoop:hadoop-aws:3.3.4,org.postgresql:postgresql:42.7.14')
             .config('spark.sql.session.timeZone', 'UTC')
             .config('spark.sql.ansi.enabled', 'true')
             .config('spark.sql.shuffle.partitions', '4')
             .config('spark.sql.sources.parallelPartitionDiscovery.threshold', '10000')
             .config('spark.ui.showConsoleProgress', 'false')
             .config('spark.speculation', 'false')
             .config('spark.hadoop.fs.s3a.endpoint', required('S3_ENDPOINT'))
             .config('spark.hadoop.fs.s3a.endpoint.region', os.environ.get('AWS_DEFAULT_REGION', 'us-east-1'))
             .config('spark.hadoop.fs.s3a.path.style.access', 'true')
             .config('spark.hadoop.fs.s3a.connection.ssl.enabled', str(required('S3_ENDPOINT').startswith('https://')).lower())
             .config('spark.hadoop.fs.s3a.aws.credentials.provider', 'org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider')
             .config('spark.hadoop.fs.s3a.access.key', required('AWS_ACCESS_KEY_ID'))
             .config('spark.hadoop.fs.s3a.secret.key', required('AWS_SECRET_ACCESS_KEY'))
             .getOrCreate())
    spark.sparkContext.setLogLevel('WARN')
    hadoop = spark.sparkContext._jvm.org.apache.hadoop.util.VersionInfo.getVersion()
    if hadoop != '3.3.4':
        spark.stop()
        raise RuntimeError(f'Expected Hadoop 3.3.4; found {hadoop}. Use the supplied Docker image.')
    return spark


def read_table(spark, layout, table, fmt):
    path = f"s3a://{required('S3_BUCKET')}/{s3_key(layout, table, fmt)}/"
    # List the directory once, then filter its children instead of globbing 1,000 roots.
    reader = (spark.read.schema(spark_schema(table)).option('mode', 'FAILFAST')
              .option('pathGlobFilter', f'part-*.{fmt}'))
    if fmt == 'csv':
        # Validate CSV header order against the declared schema.
        frame = reader.option('header', True).option('enforceSchema', False).csv(path)
    elif fmt == 'json':
        frame = reader.option('multiLine', False).json(path)
    else:
        frame = reader.parquet(path)
    expected_files, rows_per_file = LAYOUTS[layout]
    if len(frame.inputFiles()) != expected_files:
        raise ValueError(f'{table}: expected {expected_files} source files, found {len(frame.inputFiles())}')
    frame = frame.persist(StorageLevel.MEMORY_AND_DISK)
    try:
        count = frame.count()
        if count != expected_files * rows_per_file:
            raise ValueError(f'{table}: unexpected row count {count}')
        nulls = reduce(lambda left, right: left | right, [F.col(c).isNull() for c in frame.columns])
        if frame.filter(nulls).limit(1).count():
            raise ValueError(f'{table}: null or invalid required value')
        primary = MODEL['tables'][table][0].name
        if frame.select(primary).distinct().count() != count:
            raise ValueError(f'{table}: duplicate primary keys in source')
        print(f'{table}: {expected_files} files, {count} rows, {frame.rdd.getNumPartitions()} read partitions', flush=True)
        return frame, count
    except Exception:
        frame.unpersist()
        raise


def publish(frame, conn, schema, table, expected, partitions):
    target = sql.Identifier(schema, table)
    stage_name = '_load_' + uuid.uuid4().hex
    stage = sql.Identifier(schema, stage_name)
    # LIKE copies data types and NOT NULL, but no PK/FK/indexes by default.
    conn.execute(sql.SQL('CREATE TABLE {} (LIKE {})').format(stage, target))
    try:
        jdbc = f"jdbc:postgresql://{required('PGHOST')}:{os.environ.get('PGPORT', '5432')}/{required('PGDATABASE')}"
        (frame.repartition(partitions).write.format('jdbc').mode('append')
         .option('url', jdbc).option('dbtable', f'{schema}.{stage_name}')
         .option('user', required('PGUSER')).option('password', required('PGPASSWORD'))
         .option('driver', 'org.postgresql.Driver').option('batchsize', '5000')
         .option('numPartitions', partitions).option('isolationLevel', 'READ_COMMITTED').save())
        columns = sql.SQL(', ').join(sql.Identifier(c.name) for c in MODEL['tables'][table])
        with conn.transaction():
            conn.execute(sql.SQL('LOCK TABLE {} IN EXCLUSIVE MODE').format(target))
            if conn.execute(sql.SQL('SELECT EXISTS (SELECT 1 FROM {})').format(target)).fetchone()[0]:
                raise ValueError(f'{schema}.{table} is not empty; refusing to append duplicate data')
            # A JDBC task may commit and then retry. Remove exact retry duplicates in staging.
            result = conn.execute(sql.SQL('INSERT INTO {} ({}) SELECT DISTINCT {} FROM {}').format(target, columns, columns, stage))
            if result.rowcount != expected:
                raise ValueError(f'{table}: staged row count does not match source; transaction rolled back')
        print(f'COMMITTED {schema}.{table}: {expected} rows', flush=True)
    finally:
        conn.execute(sql.SQL('DROP TABLE IF EXISTS {}').format(stage))


def main(fmt):
    parser = argparse.ArgumentParser(description=f'Load banking {fmt} from Floci S3 into PostgreSQL.')
    parser.add_argument('--layout', choices=LAYOUTS, required=True)
    parser.add_argument('--tables', default='all', help='all or comma-separated table names; parents must be loaded first')
    parser.add_argument('--jdbc-partitions', type=int, default=2)
    args = parser.parse_args()
    if not 1 <= args.jdbc_partitions <= 8:
        parser.error('--jdbc-partitions must be between 1 and 8 for this local lab')
    tables = selected_tables(args.tables)
    schema = f'banking_{args.layout}'
    with psycopg.connect(autocommit=True) as conn:
        # Stop before Spark starts if any selected target is missing or nonempty.
        for table in tables:
            if conn.execute(sql.SQL('SELECT EXISTS (SELECT 1 FROM {})').format(sql.Identifier(schema, table))).fetchone()[0]:
                raise ValueError(f'{schema}.{table} is not empty. Select only remaining empty tables or use a fresh database.')
        spark = session()
        try:
            for table in tables:
                frame, count = read_table(spark, args.layout, table, fmt)
                try:
                    publish(frame, conn, schema, table, count, args.jdbc_partitions)
                finally:
                    frame.unpersist()
        finally:
            spark.stop()
