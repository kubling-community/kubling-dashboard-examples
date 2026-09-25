ARG SUPERSET_BASE=apache/superset@sha256:2c4cb71e66968c385e2b36146024f99f108b82eab473d9d363c64b260a961cc2
FROM ${SUPERSET_BASE}

ARG KUBLING_SQLALCHEMY_VERSION=26.2.0

LABEL org.opencontainers.image.title="Kubling Superset"
LABEL org.opencontainers.image.description="Apache Superset with the Kubling SQLAlchemy gRPC dialect"

USER root

RUN set -eu; \
    uv pip install --python /app/.venv/bin/python --no-cache \
      "kubling-sqlalchemy==${KUBLING_SQLALCHEMY_VERSION}"; \
    test "$(/app/.venv/bin/python -c 'from importlib.metadata import version; print(version("kubling-sqlalchemy"))')" = "$KUBLING_SQLALCHEMY_VERSION"; \
    /app/.venv/bin/python -c 'from importlib.metadata import version; assert version("SQLAlchemy").startswith("2.")'

USER superset
