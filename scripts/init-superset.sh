#!/usr/bin/env bash
set -euo pipefail

: "${EXAMPLE_NAME:?EXAMPLE_NAME is required}"
: "${SUPERSET_ADMIN_USERNAME:?SUPERSET_ADMIN_USERNAME is required}"
: "${SUPERSET_ADMIN_PASSWORD:?SUPERSET_ADMIN_PASSWORD is required}"
: "${SUPERSET_ADMIN_EMAIL:?SUPERSET_ADMIN_EMAIL is required}"

asset_dir="/tmp/kubling-superset-assets"

# Exported YAML is the source of truth. Rebuild the disposable metadata database
# so each example run starts from the same dashboards.
rm -f \
  /app/superset_home/superset.db \
  /app/superset_home/superset.db-shm \
  /app/superset_home/superset.db-wal

superset db upgrade
superset init
python /workspace/scripts/create-superset-admin.py
python /workspace/scripts/package-superset-assets.py \
  "$EXAMPLE_NAME" \
  --output-directory "$asset_dir"
superset import-dashboards \
  --path "$asset_dir/${EXAMPLE_NAME}-superset-assets.zip" \
  --username "$SUPERSET_ADMIN_USERNAME"
python /workspace/scripts/configure-superset.py
