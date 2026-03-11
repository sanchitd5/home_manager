#!/usr/bin/env bash
set -euo pipefail

required=(bash curl docker docker compose jq python3)
optional=(nginx systemctl)

echo "[check-prereqs] Checking required tools..."
missing=0
for bin in "${required[@]}"; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "[check-prereqs] MISSING: $bin"
    missing=1
  else
    echo "[check-prereqs] OK: $bin"
  fi
done

echo "[check-prereqs] Checking optional tools..."
for bin in "${optional[@]}"; do
  if command -v "$bin" >/dev/null 2>&1; then
    echo "[check-prereqs] OK: $bin"
  else
    echo "[check-prereqs] WARN: optional tool not found: $bin"
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "[check-prereqs] One or more required tools are missing."
  exit 1
fi

echo "[check-prereqs] All required tools are present."
