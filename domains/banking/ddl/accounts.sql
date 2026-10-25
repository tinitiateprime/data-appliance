-- PostgreSQL DDL for accounts: large and small datasets.
-- Run parent table files first: account_products, branches.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.accounts (
    account_id BIGINT NOT NULL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES banking_large.account_products (product_id),
    branch_id BIGINT NOT NULL REFERENCES banking_large.branches (branch_id),
    opened_date DATE NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_accounts_product_id ON banking_large.accounts (product_id);

CREATE INDEX IF NOT EXISTS ix_accounts_branch_id ON banking_large.accounts (branch_id);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

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
