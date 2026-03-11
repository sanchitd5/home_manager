# n8n Import and Credentials

## Purpose

Import starter workflows and bind credentials using environment variables.

## Required Credentials

- Trello API key/token
- Telegram bot token
- Home Assistant long-lived token

## Import Steps

1. Open n8n UI.
2. Import all JSON files from `n8n/workflows/`.
3. Create credentials for Trello, Telegram, and HTTP (Home Assistant).
4. Update placeholder IDs and endpoints.
5. Keep workflows disabled until validation passes.

## Completion Authority

- Trello-first: only Trello card state marks task complete.
- Telegram replies are informational unless workflow explicitly maps them to a Trello move.

## Validation

- Trigger each workflow manually with test data.
- Confirm no node contains hardcoded secret.
