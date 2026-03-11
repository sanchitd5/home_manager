#!/usr/bin/env bash
set -euo pipefail

if command -v ollama >/dev/null 2>&1; then
  echo "[install-ollama] Ollama already installed"
  exit 0
fi

curl -fsSL https://ollama.com/install.sh | sh
echo "[install-ollama] Installed"
