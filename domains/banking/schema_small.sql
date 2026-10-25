-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.customers (
    customer_id BIGINT NOT NULL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    dob DATE NOT NULL,
    phone_number TEXT NOT NULL,
    gender TEXT NOT NULL,
    email TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_small.customer_address (
    address_id BIGINT NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES banking_small.customers (customer_id),
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    postal_code TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_customer_address_customer_id ON banking_small.customer_address (customer_id);

CREATE TABLE IF NOT EXISTS banking_small.branches (
    branch_id BIGINT NOT NULL PRIMARY KEY,
    branch_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_small.account_products (
    product_id BIGINT NOT NULL PRIMARY KEY,
    product_name TEXT NOT NULL,
    account_type TEXT NOT NULL,
    annual_rate NUMERIC(18,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_small.accounts (
    account_id BIGINT NOT NULL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES banking_small.account_products (product_id),
    branch_id BIGINT NOT NULL REFERENCES banking_small.branches (branch_id),
    opened_date DATE NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_accounts_product_id ON banking_small.accounts (product_id);

CREATE INDEX IF NOT EXISTS ix_accounts_branch_id ON banking_small.accounts (branch_id);

CREATE TABLE IF NOT EXISTS banking_small.account_owners (
    ownership_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_small.accounts (account_id),
    customer_id BIGINT NOT NULL REFERENCES banking_small.customers (customer_id),
    owner_role TEXT NOT NULL,
    UNIQUE (account_id, customer_id)
);

CREATE INDEX IF NOT EXISTS ix_account_owners_account_id ON banking_small.account_owners (account_id);

CREATE INDEX IF NOT EXISTS ix_account_owners_customer_id ON banking_small.account_owners (customer_id);

CREATE TABLE IF NOT EXISTS banking_small.checking_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_small.accounts (account_id),
    overdraft_limit NUMERIC(18,2) NOT NULL,
    debit_card_enabled BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_checking_accounts_account_id ON banking_small.checking_accounts (account_id);

CREATE TABLE IF NOT EXISTS banking_small.savings_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_small.accounts (account_id),
    minimum_balance NUMERIC(18,2) NOT NULL,
    withdrawal_limit INTEGER NOT NULL CHECK (withdrawal_limit >= 0),
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_savings_accounts_account_id ON banking_small.savings_accounts (account_id);

CREATE TABLE IF NOT EXISTS banking_small.properties (
    property_id BIGINT NOT NULL PRIMARY KEY,
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    appraised_value NUMERIC(18,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_small.vehicles (
    vehicle_id BIGINT NOT NULL PRIMARY KEY,
    vehicle_reference TEXT NOT NULL,
    manufacturer TEXT NOT NULL,
    model_year INTEGER NOT NULL,
    vehicle_value NUMERIC(18,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking_small.loans (
    loan_id BIGINT NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES banking_small.customers (customer_id),
    branch_id BIGINT NOT NULL REFERENCES banking_small.branches (branch_id),
    loan_type TEXT NOT NULL,
    principal NUMERIC(18,2) NOT NULL,
    annual_rate NUMERIC(18,2) NOT NULL,
    term_months INTEGER NOT NULL CHECK (term_months >= 0),
    origination_date DATE NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_loans_customer_id ON banking_small.loans (customer_id);

CREATE INDEX IF NOT EXISTS ix_loans_branch_id ON banking_small.loans (branch_id);

CREATE TABLE IF NOT EXISTS banking_small.home_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_small.loans (loan_id),
    property_id BIGINT NOT NULL REFERENCES banking_small.properties (property_id),
    down_payment NUMERIC(18,2) NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_home_loans_loan_id ON banking_small.home_loans (loan_id);

CREATE INDEX IF NOT EXISTS ix_home_loans_property_id ON banking_small.home_loans (property_id);

CREATE TABLE IF NOT EXISTS banking_small.personal_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_small.loans (loan_id),
    purpose TEXT NOT NULL,
    unsecured BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_personal_loans_loan_id ON banking_small.personal_loans (loan_id);

CREATE TABLE IF NOT EXISTS banking_small.auto_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_small.loans (loan_id),
    vehicle_id BIGINT NOT NULL REFERENCES banking_small.vehicles (vehicle_id),
    down_payment NUMERIC(18,2) NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_auto_loans_loan_id ON banking_small.auto_loans (loan_id);

CREATE INDEX IF NOT EXISTS ix_auto_loans_vehicle_id ON banking_small.auto_loans (vehicle_id);

CREATE TABLE IF NOT EXISTS banking_small.loan_payments (
    payment_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_small.loans (loan_id),
    due_date DATE NOT NULL,
    principal_amount NUMERIC(18,2) NOT NULL,
    interest_amount NUMERIC(18,2) NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_loan_payments_loan_id ON banking_small.loan_payments (loan_id);

CREATE TABLE IF NOT EXISTS banking_small.account_transactions (
    transaction_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_small.accounts (account_id),
    transaction_date DATE NOT NULL,
    transaction_type TEXT NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_account_transactions_account_id ON banking_small.account_transactions (account_id);
