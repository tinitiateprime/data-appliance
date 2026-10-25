-- PostgreSQL DDL for loan_payments: large and small datasets.
-- Run parent table files first: loans.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.loan_payments (
    payment_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_large.loans (loan_id),
    due_date DATE NOT NULL,
    principal_amount NUMERIC(18,2) NOT NULL,
    interest_amount NUMERIC(18,2) NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_loan_payments_loan_id ON banking_large.loan_payments (loan_id);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.loan_payments (
    payment_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_small.loans (loan_id),
    due_date DATE NOT NULL,
    principal_amount NUMERIC(18,2) NOT NULL,
    interest_amount NUMERIC(18,2) NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_loan_payments_loan_id ON banking_small.loan_payments (loan_id);
