-- PostgreSQL DDL for properties: large and small datasets.
-- Run parent table files first: none.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.properties (
    property_id BIGINT NOT NULL PRIMARY KEY,
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    appraised_value NUMERIC(18,2) NOT NULL
);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.properties (
    property_id BIGINT NOT NULL PRIMARY KEY,
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL,
    appraised_value NUMERIC(18,2) NOT NULL
);
