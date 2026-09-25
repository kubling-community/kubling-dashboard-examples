from __future__ import annotations

import os
import sys
from getpass import getpass
from importlib.metadata import version

from sqlalchemy import URL, text
from superset.app import create_app


def parse_target(target: str) -> tuple[str, int]:
    if target.startswith("["):
        host, separator, port = target[1:].partition("]:")
    else:
        host, separator, port = target.rpartition(":")
    if not separator or not host or not port:
        raise ValueError("KUBLING_GRPC_TARGET must use host:port")
    return host, int(port)


def credentials() -> tuple[str | None, str | None]:
    username = os.environ.get("KUBLING_GRPC_USERNAME")
    if username is None:
        username = input("gRPC username: ").strip() or None
    password = os.environ.get("KUBLING_GRPC_PASSWORD")
    if password is None and username:
        password = getpass("gRPC password: ")
    return username, password


def main() -> None:
    host, port = parse_target(os.environ["KUBLING_GRPC_TARGET"])
    username, password = credentials()
    schema = os.environ.get("KUBLING_SMOKE_SCHEMA")
    table = os.environ.get("KUBLING_SMOKE_TABLE")
    sql = os.environ.get("KUBLING_SMOKE_SQL")

    uri = URL.create(
        "kubling+grpc",
        username=username,
        password=password,
        host=host,
        port=port,
        database=os.environ["KUBLING_GRPC_VDB"],
        query={
            "vdb_version": os.environ["KUBLING_GRPC_VDB_VERSION"],
            "insecure": os.environ["KUBLING_GRPC_INSECURE"],
        },
    ).render_as_string(hide_password=False)

    app = create_app()
    with app.app_context():
        from superset.commands.database.test_connection import (
            TestConnectionDatabaseCommand,
        )
        from superset.daos.database import DatabaseDAO

        TestConnectionDatabaseCommand({"sqlalchemy_uri": uri}).run()

        database = DatabaseDAO.build_db_for_connection_test(
            server_cert="",
            extra="{}",
            impersonate_user=False,
            encrypted_extra="{}",
        )
        database.set_sqlalchemy_uri(uri)

        schemas = database.get_all_schema_names()
        reflected_columns: list[str] = []
        if schema and table:
            tables = database.get_all_table_names_in_schema(
                catalog=None,
                schema=schema,
            )
            if (table, schema, None) not in tables:
                raise AssertionError(f"Table {schema}.{table} was not discovered")
            with database.get_inspector(schema=schema) as inspector:
                reflected_columns = [
                    column["name"]
                    for column in inspector.get_columns(table, schema=schema)
                ]
            if not reflected_columns:
                raise AssertionError(f"Table {schema}.{table} has no reflected columns")

        row = None
        if sql:
            with database.get_sqla_engine() as engine:
                with engine.connect() as connection:
                    row = connection.execute(text(sql), {"seq": 1}).first()
            if row is None:
                raise AssertionError("Smoke query returned no rows")

        print(
            {
                "python": sys.version.split()[0],
                "superset": version("apache_superset"),
                "sqlalchemy": version("SQLAlchemy"),
                "kubling_sqlalchemy": version("kubling-sqlalchemy"),
                "engine_spec": database.db_engine_spec.__name__,
                "connection_test": "passed",
                "schema_count": len(schemas),
                "reflected_columns": reflected_columns,
                "query": "passed" if sql else "not requested",
            }
        )


if __name__ == "__main__":
    main()
