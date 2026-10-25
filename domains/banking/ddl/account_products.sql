-- PostgreSQL DDL for account_products: large and small datasets.
-- Run parent table files first: none.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.account_products (
    product_id BIGINT NOT NULL PRIMARY KEY,
    product_name TEXT NOT NULL,
    account_type TEXT NOT NULL,
    annual_rate NUMERIC(18,2) NOT NULL
);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.account_products (
    product_id BIGINT NOT NULL PRIMARY KEY,
    product_name TEXT NOT NULL,
    account_type TEXT NOT NULL,
    annual_rate NUMERIC(18,2) NOT NULL
);
