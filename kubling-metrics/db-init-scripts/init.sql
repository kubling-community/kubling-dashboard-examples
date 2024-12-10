CREATE DATABASE kbldata;

\c kbldata

-- Audit

CREATE SCHEMA IF NOT EXISTS kbl_audit AUTHORIZATION postgres;
CREATE TABLE IF NOT EXISTS kbl_audit.log_events (
	"_time" timestamptz NOT NULL,
	"_user" varchar NOT NULL,
	"_result" varchar NULL,
	"_success" bool NULL
);
ALTER TABLE kbl_audit.log_events OWNER TO postgres;
GRANT ALL ON TABLE kbl_audit.log_events TO postgres;
GRANT ALL ON SCHEMA kbl_audit TO postgres;

-- Metrics

CREATE SCHEMA IF NOT EXISTS kbl_metrics AUTHORIZATION postgres;
CREATE TABLE IF NOT EXISTS kbl_metrics.historical (
	"_time" timestamptz NOT NULL,
	"_name" varchar NOT NULL,
	"_value" float8 NOT NULL
);
ALTER TABLE kbl_metrics.historical OWNER TO postgres;
GRANT ALL ON TABLE kbl_metrics.historical TO postgres;
GRANT ALL ON SCHEMA kbl_metrics TO postgres;