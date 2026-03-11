# Operator Notes

This repository is designed for inspectable, local-first home automation.

## Decision Locks

- Baseline ingress config: `infra/nginx/nginx.conf`
- Task completion authority: Trello-first
- Bin schedule anchor: Thursday, March 12, 2026 = `Red + Green Bin`

## Implementation Rules

- Treat `entities.csv` as authority for entity IDs when populated.
- Use placeholders until entities are confirmed in Home Assistant.
- Keep scripts idempotent and safe to rerun.
- Keep secrets in `.env` files only.

## Operational Intent

- Home Assistant remains the source of device truth.
- n8n remains the orchestration engine.
- Trello remains canonical for task state transitions.
