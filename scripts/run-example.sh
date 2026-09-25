#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
example="${1:?Usage: run-example.sh EXAMPLE}"
example_dir="$repo_root/$example"
env_file="$example_dir/.env"

if [[ ! -f "$env_file" ]]; then
  printf 'Create %s from %s/.env.example and set its required values.\n' \
    "$env_file" "$example_dir" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$env_file"
set +a

required_values=(
  KUBLING_IMAGE
  SUPERSET_SECRET_KEY
  SUPERSET_ADMIN_PASSWORD
  KUBLING_GRPC_PASSWORD
  TIMESCALE_PASSWORD
)
for name in "${required_values[@]}"; do
  value="${!name-}"
  if [[ -z "$value" || "$value" == "change-me" ]]; then
    printf '%s must be set to a real value in %s\n' "$name" "$env_file" >&2
    exit 1
  fi
done

export EXAMPLE_NAME="$example"
export KUBLING_VDB_NAME="${KUBLING_VDB_NAME:-Dashboard}"
export KUBLING_VDB_VERSION="${KUBLING_VDB_VERSION:-0.1.0}"
export TIMESCALE_HOST="${TIMESCALE_HOST:-timescaledb}"
export TIMESCALE_PORT="${TIMESCALE_PORT:-5432}"
export TIMESCALE_DATABASE="${TIMESCALE_DATABASE:-kbldata}"
export TIMESCALE_USER="${TIMESCALE_USER:-postgres}"
export TIMESCALE_METRICS_SCHEMA="${TIMESCALE_METRICS_SCHEMA:-kbl_metrics}"
export TIMESCALE_AUDIT_SCHEMA="${TIMESCALE_AUDIT_SCHEMA:-kbl_audit}"
export SUPERSET_IMAGE="${SUPERSET_IMAGE:-kubling-dashboard-superset:26.2.0-py312}"

build_dir="$repo_root/.build/$example"
mkdir -p "$build_dir"
export KUBLING_PROPERTIES_FILE="$build_dir/dashboard.properties"
export KUBLING_DESCRIPTOR_BUNDLE="$build_dir/dashboard-descriptor-bundle.zip"

python3 "$repo_root/scripts/render-properties.py" \
  "$example_dir/dashboard.properties.template" \
  "$KUBLING_PROPERTIES_FILE"
"$repo_root/scripts/generate-bundle.sh" "$example" >/dev/null
python3 "$repo_root/scripts/package-superset-assets.py" "$example" >/dev/null
"$repo_root/scripts/build-superset.sh"

docker compose \
  --env-file "$env_file" \
  --file "$example_dir/docker-compose.yml" \
  up --force-recreate --remove-orphans
