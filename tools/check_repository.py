from __future__ import annotations

import ast
import json
import os
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = {
    "kubling-metrics": {"datasets": 8, "charts": 8, "dashboards": 1},
    "k8s-multicluster-metrics": {"datasets": 14, "charts": 14, "dashboards": 2},
}


def fail(message: str) -> None:
    raise SystemExit(message)


def count_yaml(directory: Path) -> int:
    return len(list(directory.rglob("*.yaml")))


def main() -> None:
    ignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
    if "**/.env" not in ignore or ".build/" not in ignore:
        fail("Local credentials and build outputs must be ignored")

    dockerfile = (ROOT / "superset/Dockerfile").read_text(encoding="utf-8")
    if '"kubling-sqlalchemy==${KUBLING_SQLALCHEMY_VERSION}"' not in dockerfile:
        fail("Superset image must install the released driver from PyPI")
    if "COPY .build" in dockerfile or "kubling_sqlalchemy-*.whl" in dockerfile:
        fail("Superset image must not depend on a local driver wheel")

    build_script = (ROOT / "scripts/build-superset.sh").read_text(encoding="utf-8")
    if "KUBLING_SQLALCHEMY_WHEEL" in build_script or "driver_wheel" in build_script:
        fail("Superset build script must not depend on a sibling checkout")

    for name, expected in EXAMPLES.items():
        example = ROOT / name
        env_example = (example / ".env.example").read_text(encoding="utf-8")
        if "KUBLING_IMAGE=kubling/kubling:latest" not in env_example:
            fail(f"{name}/.env.example must use the current public Kubling image")
        assets = example / "superset-assets"
        actual = {kind: count_yaml(assets / kind) for kind in expected}
        if actual != expected:
            fail(f"Unexpected Superset asset counts for {name}: {actual}")

        database_files = list((assets / "databases").glob("*.yaml"))
        if len(database_files) != 1:
            fail(f"Expected one Superset database asset for {name}")
        database = database_files[0].read_text(encoding="utf-8")
        expected_uri = (
            "sqlalchemy_uri: kubling+grpc://kubling:55051/"
            "Dashboard?insecure=true&vdb_version=0.1.0"
        )
        if expected_uri not in database or "@kubling:55051" in database:
            fail(f"Invalid or credential-bearing database URI for {name}")

        asset_text = "\n".join(
            path.read_text(encoding="utf-8") for path in assets.rglob("*.yaml")
        )
        if ":35432" in asset_text or "sqlalchemy_uri: kubling://" in asset_text:
            fail(f"Legacy Kubling transport remains in {name} assets")

        compose = (example / "docker-compose.yml").read_text(encoding="utf-8")
        forbidden_compose = (
            "container_name:",
            "kubling/kubling:latest",
            "35432",
            "superset_home/superset.zip",
        )
        for value in forbidden_compose:
            if value in compose:
                fail(f"{name}/docker-compose.yml contains {value!r}")
        for value in ("${KUBLING_IMAGE:?", "superset-init:", "kubling:55051"):
            if value not in compose:
                fail(f"{name}/docker-compose.yml is missing {value!r}")

        if name == "k8s-multicluster-metrics":
            for value in (
                "dataSourceType: PROVIDER_GRPC",
                "kube-provider-1",
                "kube-provider-2",
            ):
                if value not in (example / "descriptor/vdb/DashboardVDB.yaml").read_text(encoding="utf-8"):
                    fail(f"{name} provider descriptor is missing {value!r}")
            for obsolete in ("k8s.ddl", "k8s_views.ddl", "kube_cluster_1.yaml", "kube_cluster_2.yaml"):
                if (example / obsolete).exists():
                    fail(f"Legacy Kubernetes source file remains: {name}/{obsolete}")
            for value in ("kube-cluster-1:", "kube-cluster-2:", "kubling/kubernetes-provider@sha256:"):
                if value not in compose:
                    fail(f"{name}/docker-compose.yml is missing {value!r}")

            scheduler = (example / "descriptor/systasks/scheduled/save_current_metrics.js").read_text(
                encoding="utf-8"
            )
            for value in (
                "spec__initContainers",
                "spec__overhead",
                "COALESCE(CAST(jsonJqAsString",
                "GROUP BY requests.clusterName",
            ):
                if value not in scheduler:
                    fail(f"{name} scheduler is missing {value!r}")

            history_schema = (example / "db-init-scripts/init.sql").read_text(
                encoding="utf-8"
            )
            for value in (
                '"cluster_name" varchar NOT NULL',
                "create_hypertable(",
                "historical_metric_cluster_time_idx",
                "add_retention_policy(",
                "INTERVAL '30 days'",
            ):
                if value not in history_schema:
                    fail(f"{name} history schema is missing {value!r}")

            history_files = (
                "k8s.pod.cpu.total.requested.history_12.yaml",
                "k8s.pod.mem.total.requested.history_13.yaml",
            )
            for filename in history_files:
                dataset = (assets / "datasets/Kubling" / filename).read_text(
                    encoding="utf-8"
                )
                chart = (assets / "charts" / filename).read_text(encoding="utf-8")
                if "cluster_name" not in dataset:
                    fail(f"{name} history dataset lacks the cluster dimension: {filename}")
                for value in (
                    "cluster_name",
                    'comparator: "24 hours ago : now"',
                    "row_limit: 10000",
                ):
                    if value not in chart:
                        fail(f"{name} history chart {filename} is missing {value!r}")

                query_context_line = next(
                    line for line in chart.splitlines() if line.startswith("query_context: ")
                )
                query_context = json.loads(
                    ast.literal_eval(query_context_line.removeprefix("query_context: "))
                )
                query = query_context["queries"][0]
                columns = query["columns"]
                if "cluster_name" not in columns:
                    fail(
                        f"{name} history chart series column is absent from columns: "
                        f"{filename}"
                    )
                temporal_filters = [
                    item
                    for item in query["filters"]
                    if item.get("op") == "TEMPORAL_RANGE"
                ]
                if [item.get("val") for item in temporal_filters] != [
                    "24 hours ago : now"
                ]:
                    fail(
                        f"{name} history chart does not use a rolling 24-hour range: "
                        f"{filename}"
                    )

            for filename in ("k8s.pod.issues_14.yaml", "k8s.deploy.issues_3.yaml"):
                issue_dataset = (assets / "datasets/Kubling" / filename).read_text(
                    encoding="utf-8"
                )
                if "problem.clusterName" not in issue_dataset:
                    fail(f"{name} condition join lacks clusterName: {filename}")

            forbidden_assets = (
                "No filter",
                "ovewview",
                "total_memory_gb",
                "allow_render_html: true",
            )
            for value in forbidden_assets:
                if value in asset_text:
                    fail(f"{name} assets contain {value!r}")

            fixture = (example / "fixtures/fixture.yaml").read_text(encoding="utf-8")
            for value in ("initContainers:", "cpu: 500m", "memory: 256Mi"):
                if value not in fixture:
                    fail(f"{name} fixture is missing {value!r}")

        app_config = (example / "app-config.yaml").read_text(encoding="utf-8")
        for value in ("grpc:", "portNumber: 55051", "enable: true"):
            if value not in app_config:
                fail(f"{name}/app-config.yaml is missing {value!r}")

        properties_template = (example / "dashboard.properties.template").read_text(
            encoding="utf-8"
        )
        required_properties = [
            "timescale_metrics_schema = ${TIMESCALE_METRICS_SCHEMA}",
        ]
        if name == "kubling-metrics":
            required_properties.append(
                "timescale_audit_schema = ${TIMESCALE_AUDIT_SCHEMA}"
            )
        for value in required_properties:
            if value not in properties_template:
                fail(f"{name}/dashboard.properties.template is missing {value!r}")

        if (example / "superset_home" / "superset.zip").exists():
            fail(f"Binary Superset metadata remains in {name}")
        if (example / "dashboard.properties").exists():
            fail(f"Rendered credentials remain in {name}/dashboard.properties")

    scripts = list((ROOT / "scripts").glob("*.sh"))
    scripts += list(ROOT.glob("*/run-compose.sh"))
    scripts += list(ROOT.glob("*/stop-compose.sh"))
    scripts += list(ROOT.glob("*/gen-bundles.sh"))
    non_executable = [
        path.relative_to(ROOT) for path in scripts if not os.access(path, os.X_OK)
    ]
    if non_executable:
        fail(f"Shell scripts are not executable: {non_executable}")

    print(
        {
            "examples": len(EXAMPLES),
            "datasets": sum(item["datasets"] for item in EXAMPLES.values()),
            "charts": sum(item["charts"] for item in EXAMPLES.values()),
            "dashboards": sum(item["dashboards"] for item in EXAMPLES.values()),
            "transport": "kubling+grpc",
        }
    )


if __name__ == "__main__":
    main()
