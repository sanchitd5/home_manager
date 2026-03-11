# Pi4 Ollama + MCP Bootstrap

## Purpose

Run local reasoning on Pi 4 while keeping automation execution inside n8n/HA policy boundaries.

## Prerequisites

- Raspberry Pi 4B (8GB)
- Docker installed
- Network access to Home Assistant and Trello APIs

## Setup

1. Run `ollama/scripts/install-ollama.sh`.
2. Run `ollama/scripts/pull-models.sh phi3:mini`.
3. Start service via `infra/systemd/ollama.service` or Docker.
4. Configure n8n HTTP Request node to call `http://ollama:11434/api/generate`.

## Safety Pattern

- Model produces intent text only.
- n8n maps intent to an allowlisted tool/action.
- Trello remains completion authority.

## Validation

- `ollama list` shows `phi3:mini`.
- `curl http://127.0.0.1:11434/api/tags` returns model list.

## Rollback

- Disable systemd unit and stop container.
- Remove local models with `ollama rm <model>` if needed.
