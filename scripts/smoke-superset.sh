#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
driver_version="${KUBLING_SQLALCHEMY_VERSION:-26.2.0}"
superset_image="${SUPERSET_IMAGE:-kubling-dashboard-superset:${driver_version}-py312}"
secret_key="$(python3 -c 'import secrets; print(secrets.token_urlsafe(48))')"

docker_args=(
  --rm
  --interactive
  --network host
  --env "SUPERSET_CONFIG_PATH=/app/pythonpath/kubling_superset_config.py"
  --env "SUPERSET_SECRET_KEY=$secret_key"
  --env "SUPERSET_METADATA_URI=sqlite:////tmp/kubling-superset-smoke.db"
  --env "SUPERSET_WTF_CSRF_ENABLED=false"
  --env "KUBLING_GRPC_TARGET=${KUBLING_GRPC_TARGET:-127.0.0.1:55051}"
  --env "KUBLING_GRPC_VDB=${KUBLING_GRPC_VDB:-GrpcAcceptanceVDB}"
  --env "KUBLING_GRPC_VDB_VERSION=${KUBLING_GRPC_VDB_VERSION:-1}"
  --env "KUBLING_GRPC_INSECURE=${KUBLING_GRPC_INSECURE:-true}"
  --env "KUBLING_SMOKE_SCHEMA=${KUBLING_SMOKE_SCHEMA:-acceptance}"
  --env "KUBLING_SMOKE_TABLE=${KUBLING_SMOKE_TABLE:-GRPC_B2_TEST}"
  --env "KUBLING_SMOKE_SQL=${KUBLING_SMOKE_SQL:-SELECT marker, seq FROM acceptance.GRPC_B2_TEST WHERE seq = :seq}"
  --volume "$repo_root/superset/superset_config.py:/app/pythonpath/kubling_superset_config.py:ro"
  --volume "$repo_root/scripts/superset_smoke.py:/tmp/superset_smoke.py:ro"
  --entrypoint /bin/sh
)

if [[ -t 0 ]]; then
  docker_args+=(--tty)
fi
if [[ -n "${KUBLING_GRPC_USERNAME:-}" ]]; then
  docker_args+=(--env KUBLING_GRPC_USERNAME)
fi
if [[ -n "${KUBLING_GRPC_PASSWORD:-}" ]]; then
  docker_args+=(--env KUBLING_GRPC_PASSWORD)
fi

docker run "${docker_args[@]}" "$superset_image" -c \
  'superset db upgrade >/tmp/superset-migrate.log 2>&1 && python /tmp/superset_smoke.py'
