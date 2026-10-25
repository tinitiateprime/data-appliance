"""Upload one layout/format (or selected tables) from the existing local files."""
import argparse
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import os

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from settings import BANKING, LAYOUTS, required, selected_tables, s3_key


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--layout', choices=LAYOUTS, required=True)
    parser.add_argument('--format', choices=('csv', 'json', 'parquet'), required=True)
    parser.add_argument('--tables', default='all')
    parser.add_argument('--source', type=Path, default=BANKING)
    args = parser.parse_args()
    tables = selected_tables(args.tables)
    files = {}
    for table in tables:
        files[table] = sorted((args.source/args.layout/table/args.format).glob(f'part-*.{args.format}'))
        if len(files[table]) != LAYOUTS[args.layout][0]:
            raise ValueError(f'{table}: expected {LAYOUTS[args.layout][0]} source files; found {len(files[table])}')
    client = boto3.client('s3', endpoint_url=required('S3_ENDPOINT'),
                          region_name=os.environ.get('AWS_DEFAULT_REGION', 'us-east-1'),
                          config=Config(s3={'addressing_style': 'path'}))
    bucket = required('S3_BUCKET')
    try:
        client.head_bucket(Bucket=bucket)
    except ClientError as exc:
        if str(exc.response['Error']['Code']) not in ('404', 'NoSuchBucket', 'NotFound'):
            raise
        region = os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
        options = {} if region == 'us-east-1' else {'CreateBucketConfiguration': {'LocationConstraint': region}}
        client.create_bucket(Bucket=bucket, **options)
    for table in tables:
        prefix = s3_key(args.layout, table, args.format)
        # Small, bounded upload concurrency avoids serial HTTP overhead on tiny files.
        def upload(path):
            client.upload_file(str(path), bucket, f'{prefix}/{path.name}')
        with ThreadPoolExecutor(max_workers=8) as pool:
            list(pool.map(upload, files[table]))
        print(f'Uploaded {len(files[table])} files: s3://{bucket}/{prefix}/', flush=True)


if __name__ == '__main__':
    main()
