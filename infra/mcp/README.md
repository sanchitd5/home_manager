# MCP Integration Notes

This folder documents safe tool exposure for local model workflows.

## Principles

- Keep tool endpoints local to the Pi 4 LAN.
- Do not expose raw Home Assistant admin token to models.
- Use n8n as a policy and execution boundary.

## Suggested Pattern

1. Model generates intent.
2. Intent is mapped to an allowlisted tool in n8n.
3. n8n validates required fields.
4. n8n executes Home Assistant/Trello/Telegram action.
5. n8n writes an audit event to Trello comment or log.

## Minimum Guardrails

- Explicit allowlist per tool.
- Rate limit repetitive actions.
- Require deterministic arguments (no free-form service names).
- Block destructive actions unless tagged as approved.
