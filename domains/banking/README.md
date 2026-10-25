# Banking domain — large and small datasets for every table

All **16 banking tables** have separate `large` and `small` file sets in CSV, newline-delimited JSON and Parquet.

| Layout | Files per table per format | Rows per file | Rows per table per format |
|---|---:|---:|---:|
| [large](large/) | 10 | 100,000 | 1,000,000 |
| [small](small/) | 1,000 | 10 | 10,000 |

There are **48,480 data files** in total: 480 large files and 48,000 small files. CSV headers do not count as records. Dates and decimal values agree across formats.

## Folder structure

```text
domains/banking/
  large/
    customers/
      csv/part-00000.csv ... part-00009.csv
      json/part-00000.json ... part-00009.json
      parquet/part-00000.parquet ... part-00009.parquet
    accounts/...
    ...one folder for every table
  small/
    customers/
      csv/part-00000.csv ... part-00999.csv
      json/part-00000.json ... part-00999.json
      parquet/part-00000.parquet ... part-00999.parquet
    accounts/...
    ...one folder for every table
```

| Table | Large set | Small set | Grain |
|---|---|---|---|
| customers | [Files](large/customers/) | [Files](small/customers/) | Customer |
| customer_address | [Files](large/customer_address/) | [Files](small/customer_address/) | Customer address |
| branches | [Files](large/branches/) | [Files](small/branches/) | Synthetic branch |
| account_products | [Files](large/account_products/) | [Files](small/account_products/) | Synthetic checking/savings product |
| accounts | [Files](large/accounts/) | [Files](small/accounts/) | Deposit account |
| account_owners | [Files](large/account_owners/) | [Files](small/account_owners/) | Primary ownership relationship |
| checking_accounts | [Files](large/checking_accounts/) | [Files](small/checking_accounts/) | Dated checking-account snapshot |
| savings_accounts | [Files](large/savings_accounts/) | [Files](small/savings_accounts/) | Dated savings-account snapshot |
| properties | [Files](large/properties/) | [Files](small/properties/) | Synthetic property |
| vehicles | [Files](large/vehicles/) | [Files](small/vehicles/) | Synthetic vehicle |
| loans | [Files](large/loans/) | [Files](small/loans/) | Home, personal or auto loan |
| home_loans | [Files](large/home_loans/) | [Files](small/home_loans/) | Dated home-loan snapshot |
| personal_loans | [Files](large/personal_loans/) | [Files](small/personal_loans/) | Dated personal-loan snapshot |
| auto_loans | [Files](large/auto_loans/) | [Files](small/auto_loans/) | Dated auto-loan snapshot |
| loan_payments | [Files](large/loan_payments/) | [Files](small/loan_payments/) | One scheduled installment per loan |
| account_transactions | [Files](large/account_transactions/) | [Files](small/account_transactions/) | Signed account posting |

## Dated snapshots preserve valid relationships

Checking and savings tables reference only matching account types. Home, personal and auto tables reference only matching loan types. These five tables have `snapshot_id` as primary key, plus their parent ID and `snapshot_date`. The pair `(parent_id, snapshot_date)` is unique.

There are multiple snapshots per qualifying parent, allowing each subtype table to contain the same requested number of rows without inventing extra parent IDs or classifying the same account as both savings and checking. Select the latest snapshot per parent, or a particular snapshot date, before analytical joins to avoid multiplying fact rows.

## Independent layout populations

The large set has one million customer rows; the small set has ten thousand. All foreign keys stay within their own layout. The two layouts overlap in primary keys, and small snapshot values are not necessarily a prefix of large snapshot values. **Load large and small into separate schemas or namespaces.** Do not append them together.

Each active account-owning customer has four accounts: two checking and two savings; other customers have no deposit account. Each account has one primary owner. The schema supports joint owners, but this equal-count fixture does not populate them. Borrowers generally have one loan of each type, with a possible partial final group; other customers have no loans. Transactions include deposits and withdrawals for a subset of accounts, and other accounts have no events in this window.

This is a synthetic file-volume exercise. Branch/product/collateral populations are intentionally inflated to meet exact file counts. It is not a realistic market distribution, actual customer data, or Chase's internal schema/product catalog. Rates and withdrawal limits are invented training values. Loan payments are scheduled illustrative equal-principal installments, not receipts or complete amortization schedules.

## Schema and validation

The [ddl folder](ddl/) contains one PostgreSQL SQL file per table, such as
[customers.sql](ddl/customers.sql) and [accounts.sql](ddl/accounts.sql).
Each file creates its table in both `banking_large` and `banking_small`.
Follow the [execution order](ddl/README.md) so parent tables exist before foreign keys are created.

- [Large-layout PostgreSQL DDL](schema_large.sql): `banking_large` schema.
- [Small-layout PostgreSQL DDL](schema_small.sql): `banking_small` schema.
- [Rendered Mermaid ER diagram](ERD.md) and [diagram source](erd.mmd).
- [Manifest](manifest.json): relative paths, row counts, byte sizes and SHA-256 for every data file.
- [Validation report](validation_report.json): all data files, cross-format equivalence, primary/foreign keys and snapshot checks.

Validation is offline. It does not claim live Spark/PostgreSQL/FTP/S3 execution. The small layout's schema was also exercised with an adapted SQLite relational oracle, including rejection of duplicate parent/date snapshots. Repository Git attributes preserve data bytes and checksums across checkouts.

## Load files in PySpark

Clone this repository, then run in a configured Spark session:

```python
from pathlib import Path
root = Path('data-appliance/domains/banking').resolve().as_uri()
small_customers = spark.read.parquet(root + '/small/customers/parquet/part-*.parquet')
large_accounts = spark.read.parquet(root + '/large/accounts/parquet/part-*.parquet')
assert small_customers.count() == 10000
assert large_accounts.count() == 1000000
```

Adjust the root to your checkout. Supply explicit typed schemas when reading CSV or JSON. A wildcard read should target one table, format and layout. File count is not necessarily Spark task count.

The large and small sets differ in total volume as well as physical file count. To isolate small-file overhead in a benchmark, create two physical layouts of the same logical records. These files replace the earlier v2 `csv/reference`, `csv/small`, `csv/large` hierarchy; that revision remains in Git history.
