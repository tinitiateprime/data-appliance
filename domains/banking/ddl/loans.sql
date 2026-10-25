-- PostgreSQL DDL for loans: large and small datasets.
-- Run parent table files first: customers, branches.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

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

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

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
