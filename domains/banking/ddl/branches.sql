-- PostgreSQL DDL for branches: large and small datasets.
-- Run parent table files first: none.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.branches (
    branch_id BIGINT NOT NULL PRIMARY KEY,
    branch_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL
);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.branches (
    branch_id BIGINT NOT NULL PRIMARY KEY,
    branch_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state_code TEXT NOT NULL
);
