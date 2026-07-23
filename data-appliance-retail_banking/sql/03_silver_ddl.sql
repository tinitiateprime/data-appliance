CREATE SCHEMA IF NOT EXISTS banking_demo.silver;

-- Silver tables are typed, deduplicated current-state tables. Delta Change Data
-- Feed preserves row-level before/after history for downstream consumers.
CREATE TABLE IF NOT EXISTS banking_demo.silver.branches (
  branch_id STRING NOT NULL, branch_name STRING, city STRING, state STRING,
  routing_number STRING, opened_date DATE, status STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.employees (
  employee_id STRING NOT NULL, branch_id STRING, manager_employee_id STRING,
  first_name STRING, last_name STRING, job_title STRING, hire_date DATE, status STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.customers (
  customer_id STRING NOT NULL, home_branch_id STRING, first_name STRING, last_name STRING,
  date_of_birth DATE, email STRING, phone STRING, tax_id_masked STRING,
  kyc_status STRING, risk_rating STRING, customer_since DATE, status STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.customer_addresses (
  address_id STRING NOT NULL, customer_id STRING, address_type STRING, line1 STRING, line2 STRING,
  city STRING, state STRING, postal_code STRING, country_code STRING, is_primary BOOLEAN,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.credit_scores (
  credit_score_id STRING NOT NULL, customer_id STRING, score_date DATE, bureau STRING,
  score INT, score_model STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.products (
  product_id STRING NOT NULL, product_code STRING, product_name STRING, product_category STRING,
  base_interest_rate DECIMAL(9,6), default_term_months INT, is_secured BOOLEAN,
  currency_code STRING, status STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.accounts (
  account_id STRING NOT NULL, product_id STRING, branch_id STRING, account_number_masked STRING,
  opened_date DATE, closed_date DATE, status STRING, currency_code STRING,
  current_balance DECIMAL(18,2), available_balance DECIMAL(18,2),
  credit_limit DECIMAL(18,2), interest_rate DECIMAL(9,6),
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.account_holders (
  account_id STRING NOT NULL, customer_id STRING NOT NULL, holder_role STRING,
  ownership_percent DECIMAL(5,2), effective_from DATE, effective_to DATE,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.deposit_transactions (
  transaction_id STRING NOT NULL, account_id STRING, transaction_timestamp TIMESTAMP,
  posted_date DATE, transaction_type STRING, amount DECIMAL(18,2), currency_code STRING,
  channel STRING, description STRING, status STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA PARTITIONED BY (posted_date)
TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.merchants (
  merchant_id STRING NOT NULL, merchant_name STRING, merchant_category_code STRING,
  merchant_category STRING, country_code STRING, risk_level STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.cards (
  card_id STRING NOT NULL, account_id STRING, card_number_masked STRING, card_type STRING,
  network STRING, issued_date DATE, expiry_month INT, expiry_year INT,
  card_status STRING, daily_limit DECIMAL(18,2),
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.card_transactions (
  card_transaction_id STRING NOT NULL, card_id STRING, merchant_id STRING,
  transaction_timestamp TIMESTAMP, transaction_date DATE, amount DECIMAL(18,2),
  currency_code STRING, entry_mode STRING, authorization_status STRING, fraud_flag BOOLEAN,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA PARTITIONED BY (transaction_date)
TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.loans (
  loan_id STRING NOT NULL, account_id STRING, original_principal DECIMAL(18,2),
  outstanding_principal DECIMAL(18,2), origination_date DATE, maturity_date DATE,
  term_months INT, interest_rate DECIMAL(9,6), payment_frequency STRING,
  next_payment_date DATE, next_payment_amount DECIMAL(18,2),
  delinquency_days INT, loan_status STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.loan_payments (
  payment_id STRING NOT NULL, loan_id STRING, payment_timestamp TIMESTAMP,
  payment_date DATE, payment_amount DECIMAL(18,2), principal_amount DECIMAL(18,2),
  interest_amount DECIMAL(18,2), late_fee_amount DECIMAL(18,2),
  payment_method STRING, payment_status STRING,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA PARTITIONED BY (payment_date)
TBLPROPERTIES (delta.enableChangeDataFeed = true);

CREATE TABLE IF NOT EXISTS banking_demo.silver.loan_collateral (
  collateral_id STRING NOT NULL, loan_id STRING, collateral_type STRING, description STRING,
  appraised_value DECIMAL(18,2), appraisal_date DATE, lien_position INT,
  is_deleted BOOLEAN, source_updated_at TIMESTAMP, source_system STRING, batch_id STRING,
  silver_updated_at TIMESTAMP
) USING DELTA TBLPROPERTIES (delta.enableChangeDataFeed = true);
