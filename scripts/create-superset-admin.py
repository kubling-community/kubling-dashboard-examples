from __future__ import annotations

import os

from superset.app import create_app


app = create_app()
with app.app_context():
    security_manager = app.appbuilder.sm
    username = os.environ["SUPERSET_ADMIN_USERNAME"]
    if security_manager.find_user(username=username) is None:
        role = security_manager.find_role("Admin")
        user = security_manager.add_user(
            username,
            os.environ.get("SUPERSET_ADMIN_FIRSTNAME", "Kubling"),
            os.environ.get("SUPERSET_ADMIN_LASTNAME", "Admin"),
            os.environ["SUPERSET_ADMIN_EMAIL"],
            role,
            os.environ["SUPERSET_ADMIN_PASSWORD"],
        )
        if user is None:
            raise RuntimeError(f"Could not create Superset user {username}")
        print(f"Created Superset user {username}")
    else:
        print(f"Superset user {username} already exists")
