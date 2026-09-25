from __future__ import annotations

import os
import time

from sqlalchemy import URL
from superset.app import create_app


def parse_target(target: str) -> tuple[str, int]:
    if target.startswith("["):
        host, separator, port = target[1:].partition("]:")
    else:
        host, separator, port = target.rpartition(":")
    if not separator or not host or not port:
        raise ValueError("KUBLING_GRPC_TARGET must use host:port")
    return host, int(port)


host, port = parse_target(os.environ.get("KUBLING_GRPC_TARGET", "kubling:55051"))
username = os.environ.get("KUBLING_GRPC_USERNAME") or None
password = os.environ.get("KUBLING_GRPC_PASSWORD") or None
uri = URL.create(
    "kubling+grpc",
    username=username,
    password=password,
    host=host,
    port=port,
    database=os.environ.get("KUBLING_VDB_NAME", "Dashboard"),
    query={
        "vdb_version": os.environ.get("KUBLING_VDB_VERSION", "0.1.0"),
        "insecure": os.environ.get("KUBLING_GRPC_INSECURE", "true"),
    },
).render_as_string(hide_password=False)

app = create_app()
with app.app_context():
    from superset import db
    from superset.commands.database.test_connection import (
        TestConnectionDatabaseCommand,
    )
    from superset.models.core import Database

    timeout = int(os.environ.get("KUBLING_READY_TIMEOUT", "180"))
    deadline = time.monotonic() + timeout
    attempt = 0
    while True:
        attempt += 1
        try:
            TestConnectionDatabaseCommand({"sqlalchemy_uri": uri}).run()
            break
        except Exception as error:
            if time.monotonic() >= deadline:
                raise RuntimeError(
                    f"Kubling was not ready after {timeout}s: {type(error).__name__}"
                ) from error
            print(f"Waiting for Kubling gRPC (attempt {attempt}): {type(error).__name__}")
            time.sleep(3)

    database = db.session.query(Database).filter_by(database_name="Kubling").one()
    database.set_sqlalchemy_uri(uri)
    db.session.commit()
    print(
        {
            "database": database.database_name,
            "driver": "kubling+grpc",
            "target": f"{host}:{port}",
            "connection_test": "passed",
        }
    )
