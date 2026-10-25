-- PostgreSQL DDL for vehicles: large and small datasets.
-- Run parent table files first: none.
-- See README.md for the complete execution order.

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_large;

CREATE TABLE IF NOT EXISTS banking_large.vehicles (
    vehicle_id BIGINT NOT NULL PRIMARY KEY,
    vehicle_reference TEXT NOT NULL,
    manufacturer TEXT NOT NULL,
    model_year INTEGER NOT NULL,
    vehicle_value NUMERIC(18,2) NOT NULL
);

-- Synthetic teaching model: Synthetic banking scale fixtures with dated subtype snapshots

CREATE SCHEMA IF NOT EXISTS banking_small;

CREATE TABLE IF NOT EXISTS banking_small.vehicles (
    vehicle_id BIGINT NOT NULL PRIMARY KEY,
    vehicle_reference TEXT NOT NULL,
    manufacturer TEXT NOT NULL,
    model_year INTEGER NOT NULL,
    vehicle_value NUMERIC(18,2) NOT NULL
);
