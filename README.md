# Home Manager

Local-first Home Management scaffold for Raspberry Pi.

- Pi 5: Home Assistant (device control + dashboards)
- Pi 4: n8n, Ollama, webhook ingress (Nginx baseline)
- Task authority: Trello-first
- Bin anchor: Thursday, March 12, 2026 = `Red + Green Bin`

## Quick Start

1. Copy `.env.example` to `.env` and fill placeholders.
2. If Pi 4 is not flashed yet, run `./scripts/bootstrap/setup-wizard.sh` and follow the generated guide.
3. Copy `infra/docker/.env.pi4.example` to `infra/docker/.env.pi4` and fill values.
4. Run `scripts/bootstrap/check-prereqs.sh`.
5. Run `scripts/bootstrap/init-repo.sh`.
6. Configure Pi 4 services with `scripts/install/pi4-setup.sh`.
7. Apply Home Assistant files from `home-assistant/` on Pi 5.
8. Import n8n workflows from `n8n/workflows/`.
9. Flash `esphome/cyd-home-manager.yaml`.

## Repo Layout

- `docs/`: architecture, deployment, runbook, troubleshooting
- `scripts/`: bootstrap, install, validate, backup
- `infra/`: Docker/systemd/Nginx/MCP docs
- `n8n/`: workflows and import guidance
- `home-assistant/`: automations, helpers, dashboard
- `esphome/`: CYD firmware config
- `ollama/`: install/model scripts and docs

## Flow Summary

- Trello card moves to Doing -> n8n calls Home Assistant `vacuum.start`
- Completion state is read from Trello first; Telegram confirms/alerts only
- Every Thursday 18:00, create `Put Bins Out` task using March 12, 2026 anchor
- Sensor alerts create proactive Trello tasks (battery/laundry/network)

## Validation

- `scripts/validate/validate-env.sh`
- `scripts/validate/validate-yaml.sh`

## Security Notes

- Never commit tokens or secrets.
- Keep placeholders until real values are ready.
- Use local endpoints on trusted LAN where possible.
