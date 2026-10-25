# Data Appliance

Practice datasets and SQL examples for learning data ingestion, ETL, CDC,
lakehouse architecture, and analytics.

The repository contains three learning tracks:

| Track | Best for | Technologies |
| --- | --- | --- |
| [General data](general-data/) | File-ingestion labs, format comparisons, performance testing, and CDC exercises | CSV, JSON, Parquet, PostgreSQL |
| [Retail banking](data-appliance-retail_banking/) | A complete Bronze-to-Silver-to-Gold banking project | Databricks, Spark SQL, Delta Lake |
| [Domain datasets — banking](domains/banking/) | Every banking table: 1,000 ten-row files and 10 hundred-thousand-row files per format | CSV, JSON, Parquet, PostgreSQL DDL |

> The data is intended for training and demonstrations. It does not contain real
> customer or banking information.

## Repository layout

```text
data-appliance/
├── domains/
│   └── banking/   # Generated banking data, schema, manifest and validation report
├── general-data/
│   ├── DDL/
│   │   └── ddl.sql
│   └── 01_...zip through 11_...zip
└── data-appliance-retail_banking/
    ├── csv/       # 15 banking tables in CSV format
    ├── json/      # The same 15 tables in JSON format
    ├── parquet/   # The same 15 tables in Parquet format
    └── sql/       # Databricks medallion pipeline and reports
```

## 1. General data

The [general-data](general-data/) track provides progressively more challenging
files for ingestion and ETL practice. Every archive includes CSV, JSON, and
Parquet data, allowing students to compare formats while working with the same
business scenario.

### Dataset catalog

| # | Dataset | Learning focus |
| ---: | --- | --- |
| 01 | [Many small customer files](general-data/01_many_small_json_customer.zip) | Basic ingestion and validation |
| 02 | [Many small files for multiple tables](general-data/02_many_small_json_multiple_tables.zip) | Multi-table orchestration |
| 03 | [Large sales files](general-data/03_many_large_json_sales.zip) | Large-file and semi-structured processing |
| 04 | [Many small employee files](general-data/04_many_small_csv_emp.zip) | Small-file ingestion and schema checks |
| 05 | [Many small files for multiple tables](general-data/05_many_small_csv_multiple_tables.zip) | File routing and pipeline coordination |
| 06 | [Large employee files](general-data/06_many_large_csv_emp.zip) | Bulk-load performance |
| 07 | [Many small transaction files](general-data/07_many_small_parquet_transaction.zip) | Incremental transaction processing |
| 08 | [Many small files for multiple tables](general-data/08_many_small_parquet_multiple_tables.zip) | Parquet ingestion across several tables |
| 09 | [Large sales files](general-data/09_many_large_parquet_sales.zip) | Partitioning and analytical performance |
| 10 | [Ultra-high file-count dataset](general-data/10_ultra_one_million_files.zip) | File-discovery and small-file stress testing |
| 11 | [Millions of updates and deletes](general-data/11_millions_updates_deletes.zip) | CDC, merge, update, and delete logic |

Archive names indicate the primary exercise, but each archive contains all three
supported file formats.

### Database setup

[DDL](general-data/DDL/) means **Data Definition Language**. These SQL
statements create the database objects needed before data is loaded.

The PostgreSQL [`ddl.sql`](general-data/DDL/ddl.sql) script:

- Creates the `training` schema.
- Creates customer, product, location, sales, employee, department, project,
  transaction, staging, and audit tables.
- Adds indexes for common joins and lookups.
- Adds a function that applies staged transaction updates and deletes.

Run it from the repository root:

```bash
psql -h <host> -p <port> -U <username> -d <database> \
  -f general-data/DDL/ddl.sql
```

Replace the placeholders with your PostgreSQL connection details. The user must
have permission to create schemas, tables, indexes, and functions.

## 2. Retail banking lakehouse

The [retail-banking project](data-appliance-retail_banking/) is an end-to-end
Databricks and Delta Lake example. It includes 15 related banking entities:

- Customers, addresses, credit scores, accounts, and account holders
- Branches, employees, products, cards, and merchants
- Deposit transactions, card transactions, loans, loan payments, and collateral

Each entity is supplied in [CSV](data-appliance-retail_banking/csv/),
[JSON](data-appliance-retail_banking/json/), and
[Parquet](data-appliance-retail_banking/parquet/) so students can change source
formats without changing the business model.

### Medallion architecture

```text
Source files
    │
    ▼
Bronze ── raw strings, CDC metadata, ingestion time, source file
    │
    ▼
Silver ── typed and deduplicated current state, soft deletes, Delta CDF
    │
    ▼
Gold ──── customer, product, and branch dimensions plus reporting facts
    │
    ▼
Reports ─ deposits, card activity, loans, delinquency, Customer 360, branches
```

### Run the banking project

Requirements:

- A Databricks workspace with Unity Catalog and Delta Lake
- Permission to create the `banking_demo` catalog and its schemas
- A Databricks Volume or equivalent landing location for the source files

Upload the `csv`, `json`, and `parquet` folders so the landing structure is:

```text
/Volumes/banking_demo/landing/source_data/
├── csv/
├── json/
└── parquet/
```

Then run the scripts in order:

| Step | Script | Purpose |
| ---: | --- | --- |
| 1 | [`01_bronze_ddl.sql`](data-appliance-retail_banking/sql/01_bronze_ddl.sql) | Create the catalog, Bronze schema, and raw Delta tables |
| 2 | [`02_bronze_load.sql`](data-appliance-retail_banking/sql/02_bronze_load.sql) | Load mixed-format files with `COPY INTO` |
| 3 | [`03_silver_ddl.sql`](data-appliance-retail_banking/sql/03_silver_ddl.sql) | Create typed Silver tables with Change Data Feed |
| 4 | [`04_silver_cdc_merge.sql`](data-appliance-retail_banking/sql/04_silver_cdc_merge.sql) | Deduplicate and merge inserts, updates, and soft deletes |
| 5 | [`05_gold_ddl.sql`](data-appliance-retail_banking/sql/05_gold_ddl.sql) | Create analytical dimensions and fact tables |
| 6 | [`06_gold_transform.sql`](data-appliance-retail_banking/sql/06_gold_transform.sql) | Populate the Gold reporting layer |
| 7 | [`07_six_reports.sql`](data-appliance-retail_banking/sql/07_six_reports.sql) | Run six business reports |

If you use a different catalog or landing location, replace `banking_demo` and
the `/Volumes/banking_demo/landing/source_data/` path in the SQL scripts.

### Reporting examples

The final script demonstrates:

1. Deposit balances and account counts by product and branch
2. Monthly card spending, approval rates, and fraud rates
3. Loan portfolio and loan-to-value analysis
4. Delinquency aging and exposure
5. Customer 360 and cross-sell opportunities
6. A branch performance scorecard

## Suggested learning path

1. Start with general datasets 01–04 to learn schema inspection and ingestion.
2. Use datasets 05–10 to explore orchestration and performance trade-offs.
3. Use dataset 11 to practice CDC and merge processing.
4. Complete the retail-banking scripts to build a full medallion pipeline.
5. Modify a source record and trace the change from Bronze through the reports.

