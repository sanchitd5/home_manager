# Architecture Summary

## Purpose

Summarize deployment topology and integration boundaries.

## Topology

- Pi 5: Home Assistant
- Pi 4: n8n + Ollama + Nginx ingress

## Canonical Decisions

- Ingress baseline: `infra/nginx/nginx.conf`
- Completion authority: Trello-first
- Bin anchor: Thursday, March 12, 2026 => `Red + Green Bin`

## Integrations

- Trello webhooks -> n8n
- n8n -> Home Assistant service calls
- n8n -> Telegram notifications
- Home Assistant helpers -> ESPHome and dashboard display

## Assumptions

- `entities.csv` currently has headers only; entity IDs are placeholders.
- Architecture PDF is present and should be manually reviewed during final binding.
