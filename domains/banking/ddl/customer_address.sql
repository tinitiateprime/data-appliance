-- PostgreSQL DDL for customer_address: large and small datasets.
-- Run parent table files first: customers.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.customer_address (
    address_id BIGINT NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES banking_large.customers (customer_id),
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    postal_code TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_customer_address_customer_id ON banking_large.customer_address (customer_id);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.customer_address (
    address_id BIGINT NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES banking_small.customers (customer_id),
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    postal_code TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_customer_address_customer_id ON banking_small.customer_address (customer_id);
