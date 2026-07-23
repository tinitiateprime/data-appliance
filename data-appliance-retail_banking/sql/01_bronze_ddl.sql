-- Databricks / Spark SQL. Replace `banking_demo` if another catalog is used.
CREATE CATALOG IF NOT EXISTS banking_demo;
CREATE SCHEMA IF NOT EXISTS banking_demo.bronze;

-- Bronze preserves source values as strings plus the source CDC envelope.
-- This deliberately postpones validation and typing until Silver.
CREATE TABLE IF NOT EXISTS banking_demo.bronze.branches (
  branch_id STRING, branch_name STRING, city STRING, state STRING,
  routing_number STRING, opened_date STRING, status STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.employees (
  employee_id STRING, branch_id STRING, manager_employee_id STRING,
  first_name STRING, last_name STRING, job_title STRING, hire_date STRING, status STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.customers (
  customer_id STRING, home_branch_id STRING, first_name STRING, last_name STRING,
  date_of_birth STRING, email STRING, phone STRING, tax_id_masked STRING,
  kyc_status STRING, risk_rating STRING, customer_since STRING, status STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.customer_addresses (
  address_id STRING, customer_id STRING, address_type STRING, line1 STRING, line2 STRING,
  city STRING, state STRING, postal_code STRING, country_code STRING, is_primary STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.credit_scores (
  credit_score_id STRING, customer_id STRING, score_date STRING, bureau STRING,
  score STRING, score_model STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.products (
  product_id STRING, product_code STRING, product_name STRING, product_category STRING,
  base_interest_rate STRING, default_term_months STRING, is_secured STRING,
  currency_code STRING, status STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.accounts (
  account_id STRING, product_id STRING, branch_id STRING, account_number_masked STRING,
  opened_date STRING, closed_date STRING, status STRING, currency_code STRING,
  current_balance STRING, available_balance STRING, credit_limit STRING, interest_rate STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.account_holders (
  account_id STRING, customer_id STRING, holder_role STRING, ownership_percent STRING,
  effective_from STRING, effective_to STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.deposit_transactions (
  transaction_id STRING, account_id STRING, transaction_timestamp STRING, posted_date STRING,
  transaction_type STRING, amount STRING, currency_code STRING, channel STRING,
  description STRING, status STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.merchants (
  merchant_id STRING, merchant_name STRING, merchant_category_code STRING,
  merchant_category STRING, country_code STRING, risk_level STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.cards (
  card_id STRING, account_id STRING, card_number_masked STRING, card_type STRING,
  network STRING, issued_date STRING, expiry_month STRING, expiry_year STRING,
  card_status STRING, daily_limit STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.card_transactions (
  card_transaction_id STRING, card_id STRING, merchant_id STRING,
  transaction_timestamp STRING, amount STRING, currency_code STRING, entry_mode STRING,
  authorization_status STRING, fraud_flag STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.loans (
  loan_id STRING, account_id STRING, original_principal STRING, outstanding_principal STRING,
  origination_date STRING, maturity_date STRING, term_months STRING, interest_rate STRING,
  payment_frequency STRING, next_payment_date STRING, next_payment_amount STRING,
  delinquency_days STRING, loan_status STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.loan_payments (
  payment_id STRING, loan_id STRING, payment_timestamp STRING, payment_amount STRING,
  principal_amount STRING, interest_amount STRING, late_fee_amount STRING,
  payment_method STRING, payment_status STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.bronze.loan_collateral (
  collateral_id STRING, loan_id STRING, collateral_type STRING, description STRING,
  appraised_value STRING, appraisal_date STRING, lien_position STRING,
  op STRING, source_updated_at STRING, source_system STRING, batch_id STRING,
  bronze_ingested_at TIMESTAMP, source_file STRING
) USING DELTA;
