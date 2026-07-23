-- Upload `banking_lakehouse/source_data` to this example Volume path, or
-- replace the path prefix below with your landing location.
-- COPY INTO matches the explicitly aliased metadata and source business
-- columns to the Bronze target by name.

-- Mixed-format source routing. Every table is also available in every format,
-- so these paths may be swapped when testing a connector.
COPY INTO banking_demo.bronze.branches
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/csv/branches')
FILEFORMAT = CSV FORMAT_OPTIONS ('header'='true') COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.employees
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/json/employees')
FILEFORMAT = JSON COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.customers
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/parquet/customers')
FILEFORMAT = PARQUET COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.customer_addresses
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/json/customer_addresses')
FILEFORMAT = JSON COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.credit_scores
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/csv/credit_scores')
FILEFORMAT = CSV FORMAT_OPTIONS ('header'='true') COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.products
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/parquet/products')
FILEFORMAT = PARQUET COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.accounts
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/parquet/accounts')
FILEFORMAT = PARQUET COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.account_holders
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/csv/account_holders')
FILEFORMAT = CSV FORMAT_OPTIONS ('header'='true') COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.deposit_transactions
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/json/deposit_transactions')
FILEFORMAT = JSON COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.merchants
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/csv/merchants')
FILEFORMAT = CSV FORMAT_OPTIONS ('header'='true') COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.cards
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/parquet/cards')
FILEFORMAT = PARQUET COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.card_transactions
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/json/card_transactions')
FILEFORMAT = JSON COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.loans
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/parquet/loans')
FILEFORMAT = PARQUET COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.loan_payments
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/csv/loan_payments')
FILEFORMAT = CSV FORMAT_OPTIONS ('header'='true') COPY_OPTIONS ('force'='false');
COPY INTO banking_demo.bronze.loan_collateral
FROM (SELECT *, current_timestamp() AS bronze_ingested_at, _metadata.file_path AS source_file FROM '/Volumes/banking_demo/landing/source_data/json/loan_collateral')
FILEFORMAT = JSON COPY_OPTIONS ('force'='false');

