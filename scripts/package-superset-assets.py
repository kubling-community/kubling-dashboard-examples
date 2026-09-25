from __future__ import annotations

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_EXAMPLES = ("kubling-metrics", "k8s-multicluster-metrics")


def write_file(archive: ZipFile, source: Path, archive_name: str) -> None:
    info = ZipInfo(archive_name, date_time=(1980, 1, 1, 0, 0, 0))
    info.compress_type = ZIP_DEFLATED
    info.external_attr = 0o100644 << 16
    archive.writestr(info, source.read_bytes())


def package(example: str, output_directory: Path) -> Path:
    source = REPOSITORY_ROOT / example / "superset-assets"
    if not (source / "metadata.yaml").is_file():
        raise SystemExit(f"Superset assets not found for {example}: {source}")

    old_transport = []
    for candidate in source.rglob("*.yaml"):
        content = candidate.read_text(encoding="utf-8")
        if ":35432" in content or "sqlalchemy_uri: kubling://" in content:
            old_transport.append(candidate.relative_to(source))
    if old_transport:
        raise SystemExit(f"Legacy Kubling transport remains in {old_transport}")

    output_directory.mkdir(parents=True, exist_ok=True)
    destination = output_directory / f"{example}-superset-assets.zip"
    with ZipFile(destination, "w") as archive:
        for candidate in sorted(path for path in source.rglob("*") if path.is_file()):
            relative = candidate.relative_to(source)
            write_file(archive, candidate, f"dashboard_export/{relative.as_posix()}")
    return destination


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("examples", nargs="*", default=DEFAULT_EXAMPLES)
    parser.add_argument(
        "--output-directory",
        type=Path,
        default=REPOSITORY_ROOT / ".build" / "superset-assets",
    )
    arguments = parser.parse_args()

    for example in arguments.examples:
        print(package(example, arguments.output_directory))


if __name__ == "__main__":
    main()
