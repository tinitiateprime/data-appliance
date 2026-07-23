-- Idempotent CDC processing:
--   I/U => insert or replace latest state
--   D   => keep a soft-deleted current image
-- Delta CDF on every Silver table retains insert/update preimage/update
-- postimage/delete events. Query with table_changes('table', start_version).

CREATE OR REPLACE TEMP VIEW stg_branches AS
SELECT branch_id, branch_name, city, state, routing_number, try_cast(opened_date AS DATE) opened_date, upper(status) status,
       op = 'D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.branches
QUALIFY row_number() OVER (PARTITION BY branch_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC) = 1;
MERGE INTO banking_demo.silver.branches t USING stg_branches s ON t.branch_id=s.branch_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_employees AS
SELECT employee_id, branch_id, nullif(manager_employee_id,'') manager_employee_id,
       first_name, last_name, job_title, try_cast(hire_date AS DATE) hire_date, upper(status) status,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.employees
QUALIFY row_number() OVER (PARTITION BY employee_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.employees t USING stg_employees s ON t.employee_id=s.employee_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_customers AS
SELECT customer_id, home_branch_id, initcap(trim(first_name)) first_name, initcap(trim(last_name)) last_name,
       try_cast(date_of_birth AS DATE) date_of_birth, lower(trim(email)) email, phone, tax_id_masked,
       upper(kyc_status) kyc_status, upper(risk_rating) risk_rating,
       try_cast(customer_since AS DATE) customer_since, upper(status) status,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.customers
QUALIFY row_number() OVER (PARTITION BY customer_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.customers t USING stg_customers s ON t.customer_id=s.customer_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_customer_addresses AS
SELECT address_id, customer_id, upper(address_type) address_type, trim(line1) line1, nullif(trim(line2),'') line2,
       initcap(trim(city)) city, upper(state) state, postal_code, upper(country_code) country_code,
       coalesce(try_cast(is_primary AS BOOLEAN),false) is_primary,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.customer_addresses
QUALIFY row_number() OVER (PARTITION BY address_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.customer_addresses t USING stg_customer_addresses s ON t.address_id=s.address_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_credit_scores AS
SELECT credit_score_id, customer_id, try_cast(score_date AS DATE) score_date, upper(bureau) bureau,
       try_cast(score AS INT) score, score_model,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.credit_scores
WHERE try_cast(score AS INT) BETWEEN 300 AND 850
QUALIFY row_number() OVER (PARTITION BY credit_score_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.credit_scores t USING stg_credit_scores s ON t.credit_score_id=s.credit_score_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_products AS
SELECT product_id, upper(product_code) product_code, trim(product_name) product_name, upper(product_category) product_category,
       try_cast(base_interest_rate AS DECIMAL(9,6)) base_interest_rate,
       try_cast(default_term_months AS INT) default_term_months, try_cast(is_secured AS BOOLEAN) is_secured,
       upper(currency_code) currency_code, upper(status) status,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.products
QUALIFY row_number() OVER (PARTITION BY product_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.products t USING stg_products s ON t.product_id=s.product_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_accounts AS
SELECT account_id, product_id, branch_id, account_number_masked,
       try_cast(opened_date AS DATE) opened_date, try_cast(nullif(closed_date,'') AS DATE) closed_date,
       upper(status) status, upper(currency_code) currency_code,
       try_cast(current_balance AS DECIMAL(18,2)) current_balance,
       try_cast(available_balance AS DECIMAL(18,2)) available_balance,
       try_cast(credit_limit AS DECIMAL(18,2)) credit_limit,
       try_cast(interest_rate AS DECIMAL(9,6)) interest_rate,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.accounts
QUALIFY row_number() OVER (PARTITION BY account_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.accounts t USING stg_accounts s ON t.account_id=s.account_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_account_holders AS
SELECT account_id, customer_id, upper(holder_role) holder_role,
       try_cast(ownership_percent AS DECIMAL(5,2)) ownership_percent,
       try_cast(effective_from AS DATE) effective_from, try_cast(nullif(effective_to,'') AS DATE) effective_to,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.account_holders
QUALIFY row_number() OVER (PARTITION BY account_id,customer_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.account_holders t USING stg_account_holders s
ON t.account_id=s.account_id AND t.customer_id=s.customer_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_deposit_transactions AS
SELECT transaction_id, account_id, try_cast(transaction_timestamp AS TIMESTAMP) transaction_timestamp,
       try_cast(posted_date AS DATE) posted_date, upper(transaction_type) transaction_type,
       try_cast(amount AS DECIMAL(18,2)) amount, upper(currency_code) currency_code,
       upper(channel) channel, description, upper(status) status,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.deposit_transactions
QUALIFY row_number() OVER (PARTITION BY transaction_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.deposit_transactions t USING stg_deposit_transactions s ON t.transaction_id=s.transaction_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_merchants AS
SELECT merchant_id, trim(merchant_name) merchant_name, merchant_category_code,
       merchant_category, upper(country_code) country_code, upper(risk_level) risk_level,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.merchants
QUALIFY row_number() OVER (PARTITION BY merchant_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.merchants t USING stg_merchants s ON t.merchant_id=s.merchant_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_cards AS
SELECT card_id, account_id, card_number_masked, upper(card_type) card_type, upper(network) network,
       try_cast(issued_date AS DATE) issued_date, try_cast(expiry_month AS INT) expiry_month,
       try_cast(expiry_year AS INT) expiry_year, upper(card_status) card_status,
       try_cast(daily_limit AS DECIMAL(18,2)) daily_limit,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.cards
QUALIFY row_number() OVER (PARTITION BY card_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.cards t USING stg_cards s ON t.card_id=s.card_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_card_transactions AS
SELECT card_transaction_id, card_id, merchant_id,
       try_cast(transaction_timestamp AS TIMESTAMP) transaction_timestamp,
       to_date(try_cast(transaction_timestamp AS TIMESTAMP)) transaction_date,
       try_cast(amount AS DECIMAL(18,2)) amount, upper(currency_code) currency_code,
       upper(entry_mode) entry_mode, upper(authorization_status) authorization_status,
       coalesce(try_cast(fraud_flag AS BOOLEAN),false) fraud_flag,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.card_transactions
QUALIFY row_number() OVER (PARTITION BY card_transaction_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.card_transactions t USING stg_card_transactions s ON t.card_transaction_id=s.card_transaction_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_loans AS
SELECT loan_id, account_id, try_cast(original_principal AS DECIMAL(18,2)) original_principal,
       try_cast(outstanding_principal AS DECIMAL(18,2)) outstanding_principal,
       try_cast(origination_date AS DATE) origination_date, try_cast(maturity_date AS DATE) maturity_date,
       try_cast(term_months AS INT) term_months, try_cast(interest_rate AS DECIMAL(9,6)) interest_rate,
       upper(payment_frequency) payment_frequency, try_cast(next_payment_date AS DATE) next_payment_date,
       try_cast(next_payment_amount AS DECIMAL(18,2)) next_payment_amount,
       try_cast(delinquency_days AS INT) delinquency_days, upper(loan_status) loan_status,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.loans
QUALIFY row_number() OVER (PARTITION BY loan_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.loans t USING stg_loans s ON t.loan_id=s.loan_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_loan_payments AS
SELECT payment_id, loan_id, try_cast(payment_timestamp AS TIMESTAMP) payment_timestamp,
       to_date(try_cast(payment_timestamp AS TIMESTAMP)) payment_date,
       try_cast(payment_amount AS DECIMAL(18,2)) payment_amount,
       try_cast(principal_amount AS DECIMAL(18,2)) principal_amount,
       try_cast(interest_amount AS DECIMAL(18,2)) interest_amount,
       try_cast(late_fee_amount AS DECIMAL(18,2)) late_fee_amount,
       upper(payment_method) payment_method, upper(payment_status) payment_status,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.loan_payments
QUALIFY row_number() OVER (PARTITION BY payment_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.loan_payments t USING stg_loan_payments s ON t.payment_id=s.payment_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

CREATE OR REPLACE TEMP VIEW stg_loan_collateral AS
SELECT collateral_id, loan_id, upper(collateral_type) collateral_type, description,
       try_cast(appraised_value AS DECIMAL(18,2)) appraised_value,
       try_cast(appraisal_date AS DATE) appraisal_date, try_cast(lien_position AS INT) lien_position,
       op='D' is_deleted, try_cast(source_updated_at AS TIMESTAMP) source_updated_at, source_system, batch_id, current_timestamp() silver_updated_at
FROM banking_demo.bronze.loan_collateral
QUALIFY row_number() OVER (PARTITION BY collateral_id ORDER BY try_cast(source_updated_at AS TIMESTAMP) DESC, bronze_ingested_at DESC)=1;
MERGE INTO banking_demo.silver.loan_collateral t USING stg_loan_collateral s ON t.collateral_id=s.collateral_id
WHEN MATCHED AND s.source_updated_at > t.source_updated_at THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

-- Example CDC consumption:
-- SELECT * FROM table_changes('banking_demo.silver.accounts', 0);

