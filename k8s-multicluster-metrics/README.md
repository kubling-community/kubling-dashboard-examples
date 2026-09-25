
# Kubernetes multicluster metrics

This example starts two small k3s clusters, one Kubernetes provider per cluster,
Kubling, TimescaleDB and Superset. Kubling combines both provider catalogs into
the `k8s` schema. Current views ignore completed pods and calculate requests as
the larger of the app-container sum and the largest init-container request,
plus pod overhead.

The scheduler records one CPU and memory sample per cluster every 30 seconds.
The history charts open on the latest 24 hours, and TimescaleDB keeps 30 days.

From the repository root:

```bash
cp k8s-multicluster-metrics/.env.example k8s-multicluster-metrics/.env
${EDITOR:-vi} k8s-multicluster-metrics/.env
./k8s-multicluster-metrics/run-compose.sh
```

Set every `change-me` value. `KUBLING_IMAGE` must point to a build with the
current gRPC query server and provider client. The k3s and provider images are
pinned in `.env.example`; change them there when intentionally testing another
release.

The fixture creates a namespace and representative workloads in each cluster.
Open Superset at <http://localhost:8088/> and the Kubling console at
<http://localhost:8282/console>.

Remove the containers and all generated data with:

```bash
./k8s-multicluster-metrics/stop-compose.sh
```
