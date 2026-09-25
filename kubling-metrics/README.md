# Kubling metrics

Kubling exposes current telemetry through `SYSMETRICS`. This example samples
those values every 30 seconds into TimescaleDB and presents both current state
and history in Superset.

Superset talks only to Kubling over gRPC. Kubling federates its system tables
with the TimescaleDB schemas and records authentication audit events there as
well.

From the repository root:

```bash
cp kubling-metrics/.env.example kubling-metrics/.env
${EDITOR:-vi} kubling-metrics/.env
./kubling-metrics/run-compose.sh
```

Set every `change-me` value before startup. In particular, `KUBLING_IMAGE` must
refer to a build containing the current gRPC server.

Open Superset at <http://localhost:8088/> and the Kubling console at
<http://localhost:8282/console>. To remove the containers and generated data:

```bash
./kubling-metrics/stop-compose.sh
```
