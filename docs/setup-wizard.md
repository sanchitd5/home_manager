# Setup Wizard Guide

Use the wizard when Pi 4B is freshly flashed/booted and Home Assistant is already live.

## Run

```bash
./scripts/bootstrap/setup-wizard.sh
```

The wizard asks for:
- Home Assistant URL
- Pi 4 hostname
- Pi 4 username
- Install directory on Pi

If Pi is not flashed yet, the wizard prints a concrete Raspberry Pi Imager flash checklist and exits cleanly.

The wizard checks `.env` and `infra/docker/.env.pi4` first.
If any value is missing (or still `REPLACE_ME`), it asks the user and fills it interactively.

## What It Covers

- SSH into Pi 4 and verify connectivity
- Print flash instructions when Pi is not yet ready
- Install base packages and Docker (if missing)
- Sync this repository to the Pi
- Run bootstrap/init scripts on the Pi
- Bring up n8n/Ollama/Nginx stack
- Verify Home Assistant URL reachability from Pi

The wizard performs setup directly; it does not generate Markdown setup guides.

## Important Locks Included

- Ingress baseline: `infra/nginx/nginx.conf`
- Completion authority: Trello-first
- Bin cycle: 2026-03-12 Red + Green, 2026-03-19 Yellow, then weekly alternate
