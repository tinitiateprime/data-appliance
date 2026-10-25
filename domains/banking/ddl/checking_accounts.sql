-- PostgreSQL DDL for checking_accounts: large and small datasets.
-- Run parent table files first: accounts.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.checking_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_large.accounts (account_id),
    overdraft_limit NUMERIC(18,2) NOT NULL,
    debit_card_enabled BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_checking_accounts_account_id ON banking_large.checking_accounts (account_id);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.checking_accounts (
    snapshot_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_small.accounts (account_id),
    overdraft_limit NUMERIC(18,2) NOT NULL,
    debit_card_enabled BOOLEAN NOT NULL,
    snapshot_date DATE NOT NULL,
    UNIQUE (account_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS ix_checking_accounts_account_id ON banking_small.checking_accounts (account_id);
