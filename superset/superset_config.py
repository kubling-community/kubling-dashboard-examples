import os


SECRET_KEY = os.environ["SUPERSET_SECRET_KEY"]
SQLALCHEMY_DATABASE_URI = os.environ.get(
    "SUPERSET_METADATA_URI",
    "sqlite:////app/superset_home/superset.db",
)
SQLALCHEMY_ENCRYPTED_FIELD_ENGINE = "aes-gcm"
WTF_CSRF_ENABLED = os.environ.get("SUPERSET_WTF_CSRF_ENABLED", "true").lower() == "true"
