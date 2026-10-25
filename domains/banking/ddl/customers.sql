-- PostgreSQL DDL for customers: large and small datasets.
-- Run parent table files first: none.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.customers (
    customer_id BIGINT NOT NULL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    dob DATE NOT NULL,
    phone_number TEXT NOT NULL,
    gender TEXT NOT NULL,
    email TEXT NOT NULL
);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.customers (
    customer_id BIGINT NOT NULL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    dob DATE NOT NULL,
    phone_number TEXT NOT NULL,
    gender TEXT NOT NULL,
    email TEXT NOT NULL
);
