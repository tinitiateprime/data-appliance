# Banking domain — synthetic training data

Consumer banking teaching data covering checking accounts, savings accounts, home loans, personal loans and auto loans. This is not actual customer information or a representation of Chase's internal systems or current products.

## Files for each format

| Transaction layout | Files | Records per file | Total records |
|---|---:|---:|---:|
| Small | 1,000 | 10 | 10,000 |
| Large | 10 | 100,000 | 1,000,000 |

These counts apply separately to **[CSV](csv/)**, **[JSON](json/)** and **[Parquet](parquet/)**. JSON is newline-delimited; CSV headers are not counted as records. The small set is the first 10,000 transactions of the large set, so do not append both sets to the same target.

```text
domains/banking/
  csv/                         # json/ and parquet/ have the same structure
    reference/<table>/part-00000.csv
    small/account_transactions/part-00000.csv ... part-00999.csv
    large/account_transactions/part-00000.csv ... part-00009.csv
  schema.sql
  erd.mmd
  manifest.json
  validation_report.json
```

## Supporting tables

Each supporting table has one file per format under `reference/`.

| Table | Rows |
|---|---:|
| customers | 10,000 |
| customer_address | 10,000 |
| branches | 100 |
| account_products | 4 |
| accounts | 25,833 |
| account_owners | 28,416 |
| checking_accounts | 13,333 |
| savings_accounts | 12,500 |
| properties | 2,000 |
| vehicles | 3,000 |
| loans | 11,000 |
| home_loans | 2,000 |
| personal_loans | 6,000 |
| auto_loans | 3,000 |
| loan_payments | 66,000 |

Customers can own multiple accounts, and some accounts have joint owners. Some customers have multiple loan types; 4,000 customers have no loans. Every account has deposits and withdrawals in the million-row transaction set. Loan payments are the first six illustrative scheduled equal-principal installments, not payments received or a full amortization schedule.

## Schema and validation

- [PostgreSQL DDL](schema.sql), in parent-before-child order.
- [Mermaid ER diagram source](erd.mmd).
- [Manifest](manifest.json), with file paths, row counts, bytes and SHA-256 checksums. Paths are relative to this banking directory.
- [Validation report](validation_report.json): all 3,075 data files checked, formats matched, and relationships validated offline.

The SQL and relational fixtures were checked with an offline relational oracle; this report does not claim execution against live PostgreSQL or Spark services. File bytes are preserved by repository `.gitattributes` so checksum verification remains valid on Windows and Linux.

## Use locally

Clone the repository to download the full dataset:

```bash
git clone https://github.com/tinitiateprime/data-appliance.git
```

In an existing PySpark session, read the typed Parquet files:

```python
from pathlib import Path
root = Path('data-appliance/domains/banking').resolve().as_uri()
small = spark.read.parquet(root + '/parquet/small/account_transactions/part-*.parquet')
large = spark.read.parquet(root + '/parquet/large/account_transactions/part-*.parquet')
assert small.count() == 10000
assert large.count() == 1000000
```

Set `root` to your checkout location. For CSV and JSON, provide an explicit schema for identifiers, dates and decimal amounts. Run a wildcard read inside one table/layout, not across the banking directory.

The generated files total about 269 MiB. “Large” is relative to the ten-row files; actual scan partition counts depend on file sizes, formats and Spark configuration.
