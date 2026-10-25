-- PostgreSQL DDL for account_owners: large and small datasets.
-- Run parent table files first: accounts, customers.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.account_owners (
    ownership_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_large.accounts (account_id),
    customer_id BIGINT NOT NULL REFERENCES banking_large.customers (customer_id),
    owner_role TEXT NOT NULL,
    UNIQUE (account_id, customer_id)
);

CREATE INDEX IF NOT EXISTS ix_account_owners_account_id ON banking_large.account_owners (account_id);

CREATE INDEX IF NOT EXISTS ix_account_owners_customer_id ON banking_large.account_owners (customer_id);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.account_owners (
    ownership_id BIGINT NOT NULL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES banking_small.accounts (account_id),
    customer_id BIGINT NOT NULL REFERENCES banking_small.customers (customer_id),
    owner_role TEXT NOT NULL,
    UNIQUE (account_id, customer_id)
);

CREATE INDEX IF NOT EXISTS ix_account_owners_account_id ON banking_small.account_owners (account_id);

CREATE INDEX IF NOT EXISTS ix_account_owners_customer_id ON banking_small.account_owners (customer_id);
