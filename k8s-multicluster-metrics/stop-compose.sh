#!/usr/bin/env bash
set -euo pipefail

example_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "$example_dir/../scripts/stop-example.sh" "k8s-multicluster-metrics"
