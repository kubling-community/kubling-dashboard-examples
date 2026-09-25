#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
driver_version="${KUBLING_SQLALCHEMY_VERSION:-26.2.0}"
superset_base="${SUPERSET_BASE:-apache/superset@sha256:2c4cb71e66968c385e2b36146024f99f108b82eab473d9d363c64b260a961cc2}"
superset_image="${SUPERSET_IMAGE:-kubling-dashboard-superset:${driver_version}-py312}"

docker build \
  --build-arg "SUPERSET_BASE=$superset_base" \
  --build-arg "KUBLING_SQLALCHEMY_VERSION=$driver_version" \
  --tag "$superset_image" \
  --file "$repo_root/superset/Dockerfile" \
  "$repo_root"

docker run --rm --entrypoint python "$superset_image" -c \
  'from importlib.metadata import version; import sys; print({"python": sys.version.split()[0], "superset": version("apache_superset"), "sqlalchemy": version("SQLAlchemy"), "kubling_sqlalchemy": version("kubling-sqlalchemy")})'
