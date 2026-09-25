CREATE DATABASE kbldata;

\c kbldata

CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE SCHEMA IF NOT EXISTS kbl_metrics AUTHORIZATION postgres;
CREATE TABLE IF NOT EXISTS kbl_metrics.historical (
    "_time" timestamptz NOT NULL,
    "_name" varchar NOT NULL,
    "cluster_name" varchar NOT NULL,
    "_value" float8 NOT NULL
);
SELECT create_hypertable(
    'kbl_metrics.historical',
    '_time',
    if_not_exists => TRUE
);
CREATE INDEX IF NOT EXISTS historical_metric_cluster_time_idx
    ON kbl_metrics.historical ("_name", "cluster_name", "_time" DESC);
SELECT add_retention_policy(
    'kbl_metrics.historical',
    INTERVAL '30 days',
    if_not_exists => TRUE
);
ALTER TABLE kbl_metrics.historical OWNER TO postgres;
GRANT ALL ON TABLE kbl_metrics.historical TO postgres;
GRANT ALL ON SCHEMA kbl_metrics TO postgres;
