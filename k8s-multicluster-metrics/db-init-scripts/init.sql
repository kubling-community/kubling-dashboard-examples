CREATE DATABASE kbldata;

\c kbldata

CREATE SCHEMA IF NOT EXISTS kbl_metrics AUTHORIZATION postgres;
CREATE TABLE IF NOT EXISTS kbl_metrics.historical (
	"_time" timestamptz NOT NULL,
	"_name" varchar NOT NULL,
	"_value" float8 NOT NULL
);
ALTER TABLE kbl_metrics.historical OWNER TO postgres;
GRANT ALL ON TABLE kbl_metrics.historical TO postgres;
GRANT ALL ON SCHEMA kbl_metrics TO postgres;