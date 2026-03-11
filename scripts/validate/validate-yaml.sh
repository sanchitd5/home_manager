#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

python3 - "$ROOT_DIR" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
targets = [
    root / "home-assistant",
    root / "esphome",
    root / "infra",
]

errors = []
for base in targets:
    for path in base.rglob("*.yaml"):
        text = path.read_text(encoding="utf-8")
        if "\t" in text:
            errors.append(f"tab character found: {path}")

if errors:
    print("[validate-yaml] Failed:")
    for e in errors:
        print(f" - {e}")
    sys.exit(1)

print("[validate-yaml] Basic YAML style check passed (no tabs).")
PY
