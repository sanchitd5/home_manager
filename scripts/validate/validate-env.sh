#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[validate-env] Missing .env file."
  exit 1
fi

required=(
  TRELLO_API_KEY
  TRELLO_API_TOKEN
  TRELLO_BOARD_ID
  TELEGRAM_BOT_TOKEN
  TELEGRAM_CHAT_ID
  HA_BASE_URL
  HA_LONG_LIVED_TOKEN
)

missing=0
for key in "${required[@]}"; do
  if ! grep -E "^${key}=" "$ENV_FILE" >/dev/null 2>&1; then
    echo "[validate-env] Missing key: ${key}"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "[validate-env] Validation failed."
  exit 1
fi

echo "[validate-env] Required keys present."
