-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.customers (
    customer_id BIGINT NOT NULL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    dob DATE NOT NULL,
    phone_number TEXT NOT NULL,
    gender TEXT NOT NULL,
    email TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_large.customer_address (
    address_id BIGINT NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES banking_large.customers (customer_id),
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    postal_code TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_customer_address_customer_id ON banking_large.customer_address (customer_id);

CREATE TABLE IF NOT EXISTS banking_large.branches (
    branch_id BIGINT NOT NULL PRIMARY KEY,
    branch_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_large.account_products (
    product_id BIGINT NOT NULL PRIMARY KEY,
    product_name TEXT NOT NULL,
    account_type TEXT NOT NULL,
    annual_rate NUMERIC(18,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_large.accounts (
    account_id BIGINT NOT NULL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES banking_large.account_products (product_id),
    branch_id BIGINT NOT NULL REFERENCES banking_large.branches (branch_id),
    opened_date DATE NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_accounts_product_id ON banking_large.accounts (product_id);

CREATE INDEX IF NOT EXISTS ix_accounts_branch_id ON banking_large.accounts (branch_id);

CREATE TABLE IF NOT EXISTS banking_large.account_owners (
    ownership_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_large.accounts (account_id),
    customer_id BIGINT NOT NULL REFERENCES banking_large.customers (customer_id),
    owner_role TEXT NOT NULL,
    UNIQUE (account_id, customer_id)
);

CREATE INDEX IF NOT EXISTS ix_account_owners_account_id ON banking_large.account_owners (account_id);

CREATE INDEX IF NOT EXISTS ix_account_owners_customer_id ON banking_large.account_owners (customer_id);

CREATE TABLE IF NOT EXISTS banking_large.checking_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_large.accounts (account_id),
    overdraft_limit NUMERIC(18,2) NOT NULL,
    debit_card_enabled BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_checking_accounts_account_id ON banking_large.checking_accounts (account_id);

CREATE TABLE IF NOT EXISTS banking_large.savings_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_large.accounts (account_id),
    minimum_balance NUMERIC(18,2) NOT NULL,
    withdrawal_limit INTEGER NOT NULL CHECK (withdrawal_limit >= 0),
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_savings_accounts_account_id ON banking_large.savings_accounts (account_id);

CREATE TABLE IF NOT EXISTS banking_large.properties (
    property_id BIGINT NOT NULL PRIMARY KEY,
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    appraised_value NUMERIC(18,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_large.vehicles (
    vehicle_id BIGINT NOT NULL PRIMARY KEY,
    vehicle_reference TEXT NOT NULL,
    manufacturer TEXT NOT NULL,
    model_year INTEGER NOT NULL,
    vehicle_value NUMERIC(18,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_large.loans (
    loan_id BIGINT NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES banking_large.customers (customer_id),
    branch_id BIGINT NOT NULL REFERENCES banking_large.branches (branch_id),
    loan_type TEXT NOT NULL,
    principal NUMERIC(18,2) NOT NULL,
    annual_rate NUMERIC(18,2) NOT NULL,
    term_months INTEGER NOT NULL CHECK (term_months >= 0),
    origination_date DATE NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_loans_customer_id ON banking_large.loans (customer_id);

CREATE INDEX IF NOT EXISTS ix_loans_branch_id ON banking_large.loans (branch_id);

CREATE TABLE IF NOT EXISTS banking_large.home_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_large.loans (loan_id),
    property_id BIGINT NOT NULL REFERENCES banking_large.properties (property_id),
    down_payment NUMERIC(18,2) NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_home_loans_loan_id ON banking_large.home_loans (loan_id);

CREATE INDEX IF NOT EXISTS ix_home_loans_property_id ON banking_large.home_loans (property_id);

CREATE TABLE IF NOT EXISTS banking_large.personal_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_large.loans (loan_id),
    purpose TEXT NOT NULL,
    unsecured BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_personal_loans_loan_id ON banking_large.personal_loans (loan_id);

CREATE TABLE IF NOT EXISTS banking_large.auto_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_large.loans (loan_id),
    vehicle_id BIGINT NOT NULL REFERENCES banking_large.vehicles (vehicle_id),
    down_payment NUMERIC(18,2) NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_auto_loans_loan_id ON banking_large.auto_loans (loan_id);

CREATE INDEX IF NOT EXISTS ix_auto_loans_vehicle_id ON banking_large.auto_loans (vehicle_id);

CREATE TABLE IF NOT EXISTS banking_large.loan_payments (
    payment_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_large.loans (loan_id),
    due_date DATE NOT NULL,
    principal_amount NUMERIC(18,2) NOT NULL,
    interest_amount NUMERIC(18,2) NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_loan_payments_loan_id ON banking_large.loan_payments (loan_id);

CREATE TABLE IF NOT EXISTS banking_large.account_transactions (
    transaction_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_large.accounts (account_id),
    transaction_date DATE NOT NULL,
    transaction_type TEXT NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_account_transactions_account_id ON banking_large.account_transactions (account_id);
