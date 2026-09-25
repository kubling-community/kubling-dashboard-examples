from __future__ import annotations

import argparse
import os
from pathlib import Path
from string import Template


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("template", type=Path)
    parser.add_argument("output", type=Path)
    arguments = parser.parse_args()

    rendered = Template(arguments.template.read_text(encoding="utf-8")).substitute(
        os.environ
    )
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(rendered, encoding="utf-8")
    arguments.output.chmod(0o600)


if __name__ == "__main__":
    main()
