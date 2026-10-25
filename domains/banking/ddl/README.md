# Banking table DDL

One PostgreSQL SQL file per table. Each file creates the table in both `banking_large` and `banking_small`, including primary keys, foreign keys, unique constraints, checks and foreign-key indexes. Schema creation is included.

Run against an existing PostgreSQL database with permission to create schemas and tables. Run files in the following order, then load data in the same order:

1. [customers.sql](customers.sql)
2. [customer_address.sql](customer_address.sql)
3. [branches.sql](branches.sql)
4. [account_products.sql](account_products.sql)
5. [accounts.sql](accounts.sql)
6. [account_owners.sql](account_owners.sql)
7. [checking_accounts.sql](checking_accounts.sql)
8. [savings_accounts.sql](savings_accounts.sql)
9. [properties.sql](properties.sql)
10. [vehicles.sql](vehicles.sql)
11. [loans.sql](loans.sql)
12. [home_loans.sql](home_loans.sql)
13. [personal_loans.sql](personal_loans.sql)
14. [auto_loans.sql](auto_loans.sql)
15. [loan_payments.sql](loan_payments.sql)
16. [account_transactions.sql](account_transactions.sql)

From this folder, with `psql` installed and `DATABASE_URL` set (Bash example):

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f customers.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f customer_address.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f branches.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f account_products.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f accounts.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f account_owners.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f checking_accounts.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f savings_accounts.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f properties.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f vehicles.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f loans.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f home_loans.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f personal_loans.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f auto_loans.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f loan_payments.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f account_transactions.sql
```

Alternatively, open each file in your SQL client and execute it in the listed order. For only one layout, use [schema_large.sql](../schema_large.sql) or [schema_small.sql](../schema_small.sql).

Load `large/<table>/<format>/` into `banking_large.<table>` and `small/<table>/<format>/` into `banking_small.<table>`. Choose one format per load; CSV, JSON and Parquet contain equivalent records. IDs overlap between layouts.

Checking, savings and loan subtype tables contain dated snapshots. `snapshot_id` is the primary key; the parent ID plus `snapshot_date` is unique. The subtype foreign keys enforce parent existence; matching account/loan types are validated by the dataset generator, not by these foreign keys.

`CREATE ... IF NOT EXISTS` permits rerunning creation on a matching schema; it does not migrate existing tables or check that their definitions match. These scripts create empty tables and do not load or delete data.
