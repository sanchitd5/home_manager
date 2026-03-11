#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${ROOT_DIR}/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="${OUT_DIR}/n8n-backup-${STAMP}.tar.gz"

mkdir -p "$OUT_DIR"

echo "[backup-n8n] Creating backup archive: $ARCHIVE"
tar -czf "$ARCHIVE" -C "$ROOT_DIR" n8n infra/docker/.env.pi4.example .env.example
echo "[backup-n8n] Done"
