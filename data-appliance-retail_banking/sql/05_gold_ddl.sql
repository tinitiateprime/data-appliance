CREATE SCHEMA IF NOT EXISTS banking_demo.gold;

CREATE TABLE IF NOT EXISTS banking_demo.gold.dim_customer (
  customer_id STRING NOT NULL, customer_name STRING, age_band STRING,
  city STRING, state STRING, kyc_status STRING, risk_rating STRING,
  latest_credit_score INT, credit_score_band STRING, customer_since DATE,
  refreshed_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.gold.dim_product (
  product_id STRING NOT NULL, product_code STRING, product_name STRING,
  product_category STRING, base_interest_rate DECIMAL(9,6),
  default_term_months INT, is_secured BOOLEAN, refreshed_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.gold.dim_branch (
  branch_id STRING NOT NULL, branch_name STRING, city STRING, state STRING,
  active_employee_count BIGINT, refreshed_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS banking_demo.gold.fact_daily_deposit_activity (
  activity_date DATE NOT NULL, branch_id STRING, product_id STRING,
  transaction_count BIGINT, active_account_count BIGINT,
  deposit_amount DECIMAL(20,2), withdrawal_amount DECIMAL(20,2),
  fee_amount DECIMAL(20,2), net_flow DECIMAL(20,2), refreshed_at TIMESTAMP
) USING DELTA PARTITIONED BY (activity_date);

CREATE TABLE IF NOT EXISTS banking_demo.gold.fact_daily_card_spend (
  spend_date DATE NOT NULL, branch_id STRING, card_type STRING,
  merchant_category STRING, transaction_count BIGINT, approved_count BIGINT,
  declined_count BIGINT, approved_spend DECIMAL(20,2),
  fraud_transaction_count BIGINT, fraud_amount DECIMAL(20,2), refreshed_at TIMESTAMP
) USING DELTA PARTITIONED BY (spend_date);

CREATE TABLE IF NOT EXISTS banking_demo.gold.fact_loan_portfolio (
  as_of_date DATE NOT NULL, branch_id STRING, product_id STRING,
  loan_count BIGINT, original_principal DECIMAL(20,2),
  outstanding_principal DECIMAL(20,2), weighted_interest_rate DECIMAL(12,8),
  delinquent_loan_count BIGINT, delinquent_balance DECIMAL(20,2),
  collateral_value DECIMAL(20,2), principal_paid DECIMAL(20,2),
  interest_paid DECIMAL(20,2), refreshed_at TIMESTAMP
) USING DELTA PARTITIONED BY (as_of_date);

CREATE TABLE IF NOT EXISTS banking_demo.gold.customer_360 (
  customer_id STRING NOT NULL, customer_name STRING, home_branch_id STRING,
  deposit_account_count BIGINT, checking_balance DECIMAL(20,2),
  savings_balance DECIMAL(20,2), credit_card_count BIGINT,
  credit_limit DECIMAL(20,2), card_outstanding DECIMAL(20,2),
  personal_loan_balance DECIMAL(20,2), auto_loan_balance DECIMAL(20,2),
  housing_loan_balance DECIMAL(20,2), total_relationship_balance DECIMAL(20,2),
  latest_credit_score INT, risk_rating STRING, refreshed_at TIMESTAMP
) USING DELTA;
