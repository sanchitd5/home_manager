# Operations Runbook

## Purpose

Provide day-to-day operational procedures for Home Manager.

## Daily Checks

- Confirm n8n container healthy.
- Confirm Ollama reachable on port `11434`.
- Confirm Home Assistant automations are loaded.

## Weekly Checks

- Verify Thursday bin card appears with expected bin type.
- Review failed executions in n8n.
- Rotate or validate integration tokens.

## Incident Handling

- Trello outage: queue tasks locally in n8n and notify Telegram.
- Telegram outage: continue Trello + HA flow; mark notifications deferred.
- HA outage: keep Trello cards open and retry HA action later.

## Authority Model

- Trello status is canonical for completion.
- Telegram messages do not finalize tasks unless mapped to Trello move.
