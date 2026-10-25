-- PostgreSQL DDL for account_transactions: large and small datasets.
-- Run parent table files first: accounts.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

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

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

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
