-- PostgreSQL DDL for personal_loans: large and small datasets.
-- Run parent table files first: loans.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.personal_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_large.loans (loan_id),
    purpose TEXT NOT NULL,
    unsecured BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_personal_loans_loan_id ON banking_large.personal_loans (loan_id);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.personal_loans (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES banking_small.loans (loan_id),
    purpose TEXT NOT NULL,
    unsecured BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (loan_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_personal_loans_loan_id ON banking_small.personal_loans (loan_id);
