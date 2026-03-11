# Home Manager Repository Bootstrap Plan

Use this document as the implementation brief for generating a production-ready scaffold for the local-first Home Management System.

## Objective

Create a practical, maintainable repository scaffold that an operator can clone, configure, and deploy on Raspberry Pi hardware with minimal rework.

## Source Inputs (Authoritative)

The following files already exist and must be read before creating or naming anything:

- `architecture/doc.pdf`
- `entities.csv`

Rules:
- Treat these as source of truth for naming, entities, integration assumptions, and service boundaries.
- Do not invent entity IDs if they already exist in `entities.csv`.
- If there is any conflict between assumptions and source files, source files win.

## System Architecture (Required)

### Hardware split
- Primary Hub: Raspberry Pi 5 (8GB), running Home Assistant
- Manager Hub: Raspberry Pi 4B (8GB), running:
  - n8n (Docker)
  - Ollama (local)
  - Phi-3 model for local reasoning / MCP-style tool workflows

### Service roles
- Home Assistant: hardware/device interface
- n8n: logic orchestration
- Trello: task source of truth
- Telegram: notifications + human acknowledgement/confirmation channel (non-canonical)
- ESPHome CYD display: lightweight status view
- Ollama + MCP structure: local natural language + safe tool exposure

### Decisions (Locked)
- Ingress baseline: `infra/nginx/nginx.conf`
- Task completion authority: Trello-first
- Bin schedule cycle: Thursday, March 12, 2026 => `Red + Green Bin`; Thursday, March 19, 2026 => `Yellow Bin`; then alternate weekly

### Constraint
- Do not use Ryzen 5950X / RTX 3090 for 24/7 automation logic.

## Required Functional Flows

### 1) Trello commander loop
- Monitor Trello via webhook.
- When a card like `Start House Cleaning` moves to `Doing`, trigger Home Assistant `vacuum.start`.
- Completion authority is Trello-first.
- Telegram can confirm/notify, but Trello state is canonical for completion and archival.
- Archive Trello card and send status summary.

### 2) Bin scheduling logic
- Every Thursday at 18:00, create Trello card `Put Bins Out`.
- Alternate weekly using the locked cycle:
  - Thursday, March 12, 2026 => `Red + Green Bin` (week offset 0)
  - Thursday, March 19, 2026 => `Yellow Bin` (week offset 1)
- For any later Thursday, compute full-week offset from March 12, 2026:
  - even offset => `Red + Green Bin`
  - odd offset => `Yellow Bin`

### 3) Sensor-driven proactive tasks
- CCTV battery low:
  - Monitor `eufy_security` battery entities.
  - If battery < 20%, create Trello task `Charge [Camera Name]` and notify Telegram.
- Laundry finished:
  - Detect washer power active, then transition to 0.
  - Wait 10 minutes, then create Trello task `Empty Washing Machine`.
- Network degraded:
  - If measured speed < 50 Mbps, create Trello task `Check ISP`.

### 4) Display integration
- Provide ESPHome YAML for CYD showing:
  - Trello `To Do` count
  - tonight's bin type/color (derived from the locked March 12/19, 2026 cycle)

### 5) Home Assistant dashboard
- iPad-friendly dashboard YAML including:
  - Trello board view/iframe
  - task count
  - tonight's bin (derived from the locked March 12/19, 2026 cycle)

### 6) Ollama + MCP bootstrap
- Include install/bootstrap docs for Ollama on Pi 4.
- Pull Phi-3 model.
- Document local model integration path for n8n.
- Provide MCP-oriented folder and safety guidance for tool exposure.

## Required Repository Layout

Use this baseline structure (expand only when justified):

```text
.
├── README.md
├── CLAUDE.md
├── .env.example
├── .gitignore
├── docs/
│   ├── architecture-summary.md
│   ├── deployment-guide.md
│   ├── operations-runbook.md
│   ├── troubleshooting.md
│   └── decisions/
├── scripts/
│   ├── bootstrap/
│   ├── install/
│   ├── validate/
│   ├── backup/
│   └── dev/
├── infra/
│   ├── docker/
│   │   ├── docker-compose.pi4.yml
│   │   ├── .env.pi4.example
│   │   └── compose/
│   ├── systemd/
│   ├── nginx/
│   └── mcp/
├── n8n/
│   ├── workflows/
│   ├── credentials-templates/
│   ├── custom/
│   └── docs/
├── home-assistant/
│   ├── automations/
│   ├── packages/
│   ├── dashboards/
│   ├── rest_commands/
│   ├── helpers/
│   └── docs/
├── esphome/
│   ├── cyd-home-manager.yaml
│   └── docs/
├── ollama/
│   ├── Modelfile
│   ├── scripts/
│   └── docs/
├── telegram/
│   └── docs/
└── .github/
    └── workflows/
```

## Mandatory Files (With Starter Content)

Create these files with practical, non-empty starter content:

### Root
- `README.md`
- `CLAUDE.md`
- `.env.example`
- `.gitignore`

### Scripts
- `scripts/bootstrap/init-repo.sh`
- `scripts/bootstrap/check-prereqs.sh`
- `scripts/install/pi4-setup.sh`
- `scripts/install/pi5-ha-notes.sh`
- `scripts/validate/validate-env.sh`
- `scripts/validate/validate-yaml.sh`
- `scripts/backup/backup-n8n.sh`

### Infra
- `infra/docker/docker-compose.pi4.yml`
- `infra/docker/.env.pi4.example`
- `infra/systemd/ollama.service`
- `infra/systemd/home-manager-bootstrap.service`
- `infra/nginx/nginx.conf` (required ingress baseline)
- `infra/mcp/README.md`

### n8n
- `n8n/workflows/trello-ha-telegram-sync.json`
- `n8n/workflows/ha-event-ingest.json`
- `n8n/workflows/bin-reminder.json`
- `n8n/workflows/network-check.json`
- `n8n/docs/import-and-credentials.md`

### Home Assistant
- `home-assistant/automations/cctv-battery.yaml`
- `home-assistant/automations/laundry.yaml`
- `home-assistant/automations/network.yaml`
- `home-assistant/automations/bin-helper.yaml`
- `home-assistant/packages/rest-command.yaml`
- `home-assistant/helpers/input_booleans.yaml`
- `home-assistant/dashboards/ipad-home-manager.yaml`

### ESPHome
- `esphome/cyd-home-manager.yaml`

### Ollama
- `ollama/scripts/install-ollama.sh`
- `ollama/scripts/pull-models.sh`
- `ollama/docs/pi4-ollama-mcp.md`

### Docs
- `docs/deployment-guide.md`
- `docs/operations-runbook.md`
- `docs/troubleshooting.md`
- `docs/architecture-summary.md`

## Implementation Standards

### Secrets and configuration
- Never commit real credentials or tokens.
- Use placeholders and env vars.
- Include example templates for operator fill-in.

### Shell scripts
- Use `bash` + `set -euo pipefail`.
- Keep scripts idempotent where practical.
- Include clear log messages and minimal comments.
- Assume Debian/Ubuntu-like Raspberry Pi environments unless source docs specify otherwise.

### YAML/JSON
- Keep formatting clean and parseable.
- Match names/entity IDs from source inputs.
- If unknown, use explicit placeholders such as:
  - `sensor.REPLACE_WASHER_POWER`
  - `vacuum.REPLACE_EUFY_VACUUM`

### Documentation quality
Each major doc should include:
- purpose
- prerequisites
- deployment/config steps
- validation checks
- rollback notes

## Execution Rules

1. Read `architecture/doc.pdf` and `entities.csv` first.
2. Derive names/entity IDs from those sources.
3. Keep the scaffold practical, not over-engineered.
4. Preserve local-first operation on Pi 4 and Pi 5.
5. Keep boundaries clear: `infra`, `n8n`, `home-assistant`, `scripts`, `docs`.
6. Make placeholders obvious and searchable.
7. Prefer explicit, inspectable automation over hidden magic.

## Required Delivery Format

Return results in this order:

### A) Repository tree
Show final proposed tree.

### B) File contents
Provide full content for all important files listed above.

### C) Assumptions
List minimum assumptions made due to missing/incomplete source details.

### D) Next-step checklist
Provide a short operator checklist for:
- filling env vars
- importing n8n workflows
- applying Home Assistant YAML
- flashing ESPHome
- deploying Ollama
- validating end-to-end flows

## Acceptance Criteria

The result should be:
- organized
- internally consistent
- practical to deploy
- local-first
- aligned to `architecture/doc.pdf`
- aligned to `entities.csv`

If source data is incomplete, make the safest minimal assumption and state it explicitly.
