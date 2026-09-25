#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
example="${1:?Usage: generate-bundle.sh EXAMPLE}"
example_dir="$repo_root/$example"
build_dir="$repo_root/.build/$example"
cli_image="${KUBLING_CLI_IMAGE:-kubling/kubling-cli@sha256:873eb50215b794db5bb8c6ca6fc61fe60ccd2a5e42d8c83e2a372e5c98a9a6aa}"

if [[ ! -d "$example_dir/descriptor" ]]; then
  printf 'Unknown example: %s\n' "$example" >&2
  exit 1
fi

mkdir -p "$build_dir"
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --volume "$example_dir/descriptor:/descriptor:ro" \
  --volume "$build_dir:/output" \
  "$cli_image" \
  bundle genmod /descriptor \
  --output /output/dashboard-descriptor-bundle.zip \
  --parse

printf '%s\n' "$build_dir/dashboard-descriptor-bundle.zip"
