# Kubling dashboard examples

These examples run Apache Superset against Kubling through the native gRPC
SQLAlchemy dialect. TimescaleDB stores historical samples, while Kubling remains
the only database connection configured in Superset.

| Example | What it shows |
| --- | --- |
| [`kubling-metrics`](kubling-metrics/) | Kubling runtime metrics and audit history. |
| [`k8s-multicluster-metrics`](k8s-multicluster-metrics/) | A federated view of two Kubernetes clusters plus historical resource demand. |

The Superset database, datasets, charts and dashboards live as YAML under each
example's `superset-assets` directory. Startup creates a fresh Superset metadata
database and imports those assets; generated databases and ZIP files are not
source files.

## Requirements

- Docker with the Compose plugin
- network access to Docker Hub and PyPI on the first build
- the current public Kubling image selected through `kubling/kubling:latest`

The local Superset image starts from an official Apache Superset image pinned
by digest. Kubling follows the current public `latest` image.

## Run an example

Copy the sample environment and replace every `change-me` value:

```bash
cp kubling-metrics/.env.example kubling-metrics/.env
${EDITOR:-vi} kubling-metrics/.env
```

`KUBLING_IMAGE` may be a local image name or a registry reference. Use a strong,
independent value for `SUPERSET_SECRET_KEY`; for example:

```bash
openssl rand -hex 32
```

Start the stack from the repository root:

```bash
./kubling-metrics/run-compose.sh
```

The same flow works for `k8s-multicluster-metrics`. It starts two local k3s
fixtures and connects them through the released Kubernetes provider.

Once startup finishes:

- Kubling console: <http://localhost:8282/console>
- Superset: <http://localhost:8088/>

Superset connects to `kubling:55051` with `kubling+grpc`. PostgreSQL and the
legacy native Kubling transports are disabled in these examples.

Stop an example and remove its generated metadata and TimescaleDB data with:

```bash
./kubling-metrics/stop-compose.sh
```

## Updating assets

Edit or export the YAML under `superset-assets`, then verify that it packages
deterministically:

```bash
python3 scripts/package-superset-assets.py
```

The descriptor bundle and rendered properties are also generated at runtime
under `.build/`. They should never be committed.

These stacks are development examples. Review credentials, TLS, persistence and
resource limits before adapting one for a production deployment.
