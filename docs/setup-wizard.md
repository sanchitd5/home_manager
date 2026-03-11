# Setup Wizard Guide

Use the wizard when Pi 4B is not flashed yet and Home Assistant is already live.

## Run

```bash
./scripts/bootstrap/setup-wizard.sh
```

The wizard asks for:
- Home Assistant URL
- Pi 4 hostname
- Pi 4 username
- Timezone
- Repository clone URL

It prints a complete bootstrap flow and saves a copy to:

`docs/setup-guides/pi4-setup-<timestamp>.md`

## What It Covers

- Phase 1: SD card flashing with Raspberry Pi Imager
- Phase 2: first boot package prep + repo bootstrap on Pi 4
- Phase 3: n8n/HA integration and validation checks

## Important Locks Included

- Ingress baseline: `infra/nginx/nginx.conf`
- Completion authority: Trello-first
- Bin cycle: 2026-03-12 Red + Green, 2026-03-19 Yellow, then weekly alternate
