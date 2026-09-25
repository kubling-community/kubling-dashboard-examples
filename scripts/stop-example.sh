#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
example="${1:?Usage: stop-example.sh EXAMPLE}"
example_dir="$repo_root/$example"
env_file="$example_dir/.env"

if [[ ! -f "$env_file" ]]; then
  printf 'Missing %s\n' "$env_file" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$env_file"
set +a

export EXAMPLE_NAME="$example"
export KUBLING_PROPERTIES_FILE="$repo_root/.build/$example/dashboard.properties"
export KUBLING_DESCRIPTOR_BUNDLE="$repo_root/.build/$example/dashboard-descriptor-bundle.zip"
export SUPERSET_IMAGE="${SUPERSET_IMAGE:-kubling-dashboard-superset:26.2.0-py312}"

docker compose \
  --env-file "$env_file" \
  --file "$example_dir/docker-compose.yml" \
  down --volumes --remove-orphans
