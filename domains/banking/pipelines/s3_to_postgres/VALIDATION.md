# Live validation — 2026-10-25

Tested with Docker Desktop, the running Floci service on port 4566, and an isolated PostgreSQL 16 test container. The existing user database was not modified.

Runtime: Python 3.11, Java 17, PySpark 3.5.8, Hadoop client/AWS 3.3.4, PostgreSQL JDBC 42.7.14, PyArrow 25.0.1, psycopg 3.3.6 and boto3 1.43.118.

Passed checks:

- Built the Docker image and validated the Compose service configuration.
- Confirmed Docker Desktop can reach the existing published Floci 4566 and PostgreSQL 5432 ports.
- All six command-line entry points returned working `--help` output.
- Applied both complete PostgreSQL schemas with their keys, indexes and constraints.
- Uploaded and loaded 1,000 small customer CSV files, then 1,000 JSON files, with 10,000 destination rows per exercise.
- Rechecked CSV and JSON using the final directory reader with `pathGlobFilter`.
- Read all 16 small Parquet tables from Floci: 1,000 files and 10,000 rows per table. All final table counts passed with foreign keys and snapshot uniqueness enabled.
- Uploaded and loaded 10 large customer Parquet files: 100,000 rows each, 1,000,000 destination rows total.
- Refused a repeat load into a nonempty destination.
- Rolled back a mismatched staging row count and a missing-parent foreign-key violation without leaving destination rows.
- Simulated duplicate JDBC retry rows in staging and committed only one copy.
- Confirmed staging tables were removed after normal completion and handled failures.

This is a functional validation, not a performance benchmark. The full 16-table large dataset and every table in CSV/JSON were not exhaustively loaded. The same schema-driven reader and writer handle those combinations. The tutorial's PostgreSQL credentials still need to be supplied by each student in their own `.env` file.
