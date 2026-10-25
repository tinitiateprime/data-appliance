# Banking data generator scripts

These scripts generate the synthetic banking data in this repository. They run with Python; Spark, a database, FTP and AWS are not required. This is a teaching model, not Chase's internal schema or real customer data.

## What you get

| Layout | Files per table per format | Data rows per file | Total rows per table per format |
|---|---:|---:|---:|
| Small | 1,000 | 10 | 10,000 |
| Large | 10 | 100,000 | 1,000,000 |

Every one of the 16 tables follows these counts. `--format all` generates CSV, newline-delimited JSON and Snappy-compressed Parquet containing the same logical rows. CSV headers do not count as data rows. Generating both layouts and all formats produces 48,480 data files; the published dataset occupies approximately 3.16 GiB. Allow additional free disk space and time for generation. Large files are large relative to this exercise, not necessarily multi-gigabyte files.

## 1. Install Python and the dependency

Use Python 3.10 or newer with a compatible PyArrow wheel. The scripts were tested with Python 3.14 and PyArrow 25.0.1. Clone this repository, or use your existing checkout:

```bash
git clone https://github.com/tinitiateprime/data-appliance.git
cd data-appliance/domains/banking/scripts
python -m venv .venv
```

Activate the environment in **Windows PowerShell**:

```powershell
.\.venv\Scripts\Activate.ps1
```

Or activate it in **macOS/Linux Bash**:

```bash
source .venv/bin/activate
```

Then install the dependency:

```bash
python -m pip install -r requirements.txt
```

If activation is unavailable, use `.venv/Scripts/python.exe` on Windows or `.venv/bin/python` on macOS/Linux instead of `python` in subsequent commands. All examples below run from this `scripts` folder. Relative output paths are resolved from your current working directory.

## 2. Generate one table

Start with customers and CSV only:

```bash
python generate_customers.py --layout small --format csv --output ../generated_banking
```

This creates exactly 1,000 CSV files with 10 rows each in `../generated_banking/small/customers/csv/`.

Generate large customers in the same output root:

```bash
python generate_customers.py --layout large --format all --output ../generated_banking
```

This creates 10 files of 100,000 rows **for each format** under `../generated_banking/large/customers/`. To add the missing small formats later:

```bash
python generate_customers.py --layout small --format json --output ../generated_banking
python generate_customers.py --layout small --format parquet --output ../generated_banking
```

Every table uses the same arguments. For example:

```bash
python generate_accounts.py --layout small --format all --output ../generated_banking
python generate_home_loans.py --layout large --format parquet --output ../generated_banking
python generate_accounts.py --help
```

| Script | Row represented |
|---|---|
| `generate_customers.py` | Synthetic customer |
| `generate_customer_address.py` | Customer address |
| `generate_branches.py` | Synthetic branch |
| `generate_account_products.py` | Checking/savings product |
| `generate_accounts.py` | Deposit account |
| `generate_account_owners.py` | Primary account ownership |
| `generate_checking_accounts.py` | Dated checking snapshot |
| `generate_savings_accounts.py` | Dated savings snapshot |
| `generate_properties.py` | Property collateral |
| `generate_vehicles.py` | Vehicle collateral |
| `generate_loans.py` | Home, personal or auto loan |
| `generate_home_loans.py` | Dated home-loan snapshot |
| `generate_personal_loans.py` | Dated personal-loan snapshot |
| `generate_auto_loans.py` | Dated auto-loan snapshot |
| `generate_loan_payments.py` | Scheduled installment |
| `generate_account_transactions.py` | Deposit or withdrawal posting |

Generating a child table alone does not generate its parents. File generation can happen in any order because IDs are deterministic. Generate all related tables with the same layout before loading them into a database, then use the parent-first order in [the DDL instructions](../ddl/README.md).

## 3. Generate all small tables with one script

Use a fresh output root for this example, separate from the individual-table exercise:

```bash
python generate_all_small.py --format all --output ../generated_all
```

Result: 16 tables × 3 formats × 1,000 files = **48,000 small files**.

## 4. Generate all large tables with one script

Use the same root to place both layouts side by side:

```bash
python generate_all_large.py --format all --output ../generated_all
```

Result: 16 tables × 3 formats × 10 files = **480 large files**.

The all-table runners select the layout for you, so they do not accept `--layout`. Both accept `--format csv`, `--format json`, `--format parquet`, or `--format all` (the default). For example, to generate only CSV into another fresh root:

```bash
python generate_all_small.py --format csv --output ../csv_exercise
python generate_all_large.py --format csv --output ../csv_exercise
```

## Output structure

```text
generated_all/
  small/
    customers/
      csv/part-00000.csv ... part-00999.csv
      json/part-00000.json ... part-00999.json
      parquet/part-00000.parquet ... part-00999.parquet
    accounts/...
    ...all other tables
  large/
    customers/
      csv/part-00000.csv ... part-00009.csv
      json/part-00000.json ... part-00009.json
      parquet/part-00000.parquet ... part-00009.parquet
    accounts/...
    ...all other tables
  manifest.json
  schema_small.sql
  schema_large.sql
  ddl/
  ERD.md
  erd.mmd
```

The manifest records each file's row count, byte size and SHA-256 checksum. `dataset_complete` becomes true only when all 16 tables, both layouts and all three formats have been generated. A CSV-only or small-only exercise correctly leaves it false.

## How the scripts work

1. Each `generate_<table>.py` defines `generate_row(key, total)`. Read this function to understand the table's values and relationships.
2. `common.py` holds the column types, shared monetary/loan calculations, CLI and writers. It generates one file's rows at a time rather than storing the entire dataset in memory.
3. The small and large runners call the individual generators in dependency order. IDs and values repeat deterministically for the same table and layout; no random seed is needed.
4. Schema files are copied from this repository into the output. Keep this folder alongside the parent `ddl`, SQL and ERD files; the scripts do not depend on the separate PySpark tutorial repository.

Checking/savings and loan subtype tables contain dated snapshots. The same account or loan can appear on multiple dates, with a distinct `snapshot_id`. The large customer table contains one million customers; the small customer table contains ten thousand. Branch and product populations are deliberately inflated for the equal-file-count exercise. See [the domain README](../README.md) for ownership and loan population details.

Load the two layouts into separate `banking_small` and `banking_large` schemas because their IDs overlap. Choose one format for each load; loading all three formats would duplicate the logical records.

## Rerunning and troubleshooting

- Existing table/layout/format directories are never overwritten. Choose a new output root to repeat an exercise. You can add a missing table, layout or format to an existing compatible output root.
- All-table runners check all their requested destinations before starting; they do not skip existing tables. After an individual-table exercise, use a fresh root for an all-table run.
- Run one generator process at a time per output root. Concurrent processes would compete to update the same manifest.
- If a run is interrupted, partially written directories may remain. Use a fresh output root; automatic resume and cleanup are not implemented.
- `ModuleNotFoundError: pyarrow`: install `requirements.txt` using the same Python interpreter that runs the scripts.
- Generation only writes local files. It does not upload data to GitHub, S3, FTP or a database.
