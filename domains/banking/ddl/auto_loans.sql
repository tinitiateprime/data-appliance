-- PostgreSQL DDL for auto_loans: large and small datasets.
-- Run parent table files first: loans, vehicles.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

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

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

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
