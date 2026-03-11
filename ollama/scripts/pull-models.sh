#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-phi3:mini}"

echo "[pull-models] Pulling model: ${MODEL}"
ollama pull "${MODEL}"
echo "[pull-models] Done"
