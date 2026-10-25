-- PostgreSQL DDL for savings_accounts: large and small datasets.
-- Run parent table files first: accounts.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.savings_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_large.accounts (account_id),
    minimum_balance NUMERIC(18,2) NOT NULL,
    withdrawal_limit INTEGER NOT NULL CHECK (withdrawal_limit >= 0),
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_savings_accounts_account_id ON banking_large.savings_accounts (account_id);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.savings_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_small.accounts (account_id),
    minimum_balance NUMERIC(18,2) NOT NULL,
    withdrawal_limit INTEGER NOT NULL CHECK (withdrawal_limit >= 0),
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_savings_accounts_account_id ON banking_small.savings_accounts (account_id);
