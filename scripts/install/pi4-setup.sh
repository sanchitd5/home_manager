#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "[pi4-setup] Running package update"
sudo apt-get update

echo "[pi4-setup] Installing Docker dependencies"
sudo apt-get install -y ca-certificates curl gnupg lsb-release jq

if ! command -v docker >/dev/null 2>&1; then
  echo "[pi4-setup] Installing Docker"
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "${USER}"
fi

mkdir -p "${ROOT_DIR}/infra/docker/data/n8n"

if [[ ! -f "${ROOT_DIR}/infra/docker/.env.pi4" ]]; then
  cp "${ROOT_DIR}/infra/docker/.env.pi4.example" "${ROOT_DIR}/infra/docker/.env.pi4"
  echo "[pi4-setup] Created infra/docker/.env.pi4"
fi

echo "[pi4-setup] Starting Pi4 stack"
docker compose --env-file "${ROOT_DIR}/infra/docker/.env.pi4" \
  -f "${ROOT_DIR}/infra/docker/docker-compose.pi4.yml" up -d

echo "[pi4-setup] Done. Log out/in if docker group was just applied."
