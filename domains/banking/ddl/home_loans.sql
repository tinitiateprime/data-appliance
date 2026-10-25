-- PostgreSQL DDL for home_loans: large and small datasets.
-- Run parent table files first: loans, properties.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

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

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

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
