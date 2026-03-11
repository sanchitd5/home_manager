#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "[init-repo] Root: ${ROOT_DIR}"

mkdir -p \
  "${ROOT_DIR}/docs/decisions" \
  "${ROOT_DIR}/scripts/dev" \
  "${ROOT_DIR}/infra/docker/compose" \
  "${ROOT_DIR}/infra/systemd" \
  "${ROOT_DIR}/infra/nginx" \
  "${ROOT_DIR}/infra/mcp" \
  "${ROOT_DIR}/n8n/workflows" \
  "${ROOT_DIR}/n8n/credentials-templates" \
  "${ROOT_DIR}/n8n/custom" \
  "${ROOT_DIR}/n8n/docs" \
  "${ROOT_DIR}/home-assistant/automations" \
  "${ROOT_DIR}/home-assistant/packages" \
  "${ROOT_DIR}/home-assistant/dashboards" \
  "${ROOT_DIR}/home-assistant/rest_commands" \
  "${ROOT_DIR}/home-assistant/helpers" \
  "${ROOT_DIR}/home-assistant/docs" \
  "${ROOT_DIR}/esphome/docs" \
  "${ROOT_DIR}/ollama/scripts" \
  "${ROOT_DIR}/ollama/docs" \
  "${ROOT_DIR}/telegram/docs" \
  "${ROOT_DIR}/.github/workflows" \
  "${ROOT_DIR}/backups"

echo "[init-repo] Ensuring local env file exists"
if [[ ! -f "${ROOT_DIR}/.env" ]]; then
  cp "${ROOT_DIR}/.env.example" "${ROOT_DIR}/.env"
  echo "[init-repo] Created .env from .env.example"
else
  echo "[init-repo] .env already exists; leaving unchanged"
fi

echo "[init-repo] Complete."
