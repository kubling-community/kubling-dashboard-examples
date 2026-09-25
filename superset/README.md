# Superset development image

This image installs the released `kubling-sqlalchemy` package into Apache
Superset's minimal image. The driver version, Superset source commit, Python 3.12
variant and multi-platform digest are fixed in `Dockerfile`.

Build the candidate from the repository root:

```bash
./scripts/build-superset.sh
```

The build installs `kubling-sqlalchemy==26.2.0` from PyPI. Set
`KUBLING_SQLALCHEMY_VERSION`, `SUPERSET_BASE` or `SUPERSET_IMAGE` to override an
input; use a published driver version so the build remains reproducible.

With the gRPC acceptance server listening locally, run:

```bash
./scripts/smoke-superset.sh
```

The script prompts for credentials and defaults to the `GrpcAcceptanceVDB`
fixture on `127.0.0.1:55051`. Connection settings and the reflected fixture can
be changed with the `KUBLING_GRPC_*` and `KUBLING_SMOKE_*` environment variables.
It creates and migrates a temporary Superset metadata database inside the
container, then validates connection, discovery, reflection and a query.

This image is a local acceptance artifact. It is not published by these scripts.
