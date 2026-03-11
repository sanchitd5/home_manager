# Deployment Guide

## Purpose

Deploy the scaffold to Pi 4 and Pi 5 with minimal operator ambiguity.

## Prerequisites

- SSH access to both Raspberry Pis
- Docker on Pi 4
- Home Assistant running on Pi 5
- Trello and Telegram credentials ready

## Steps

1. Flash Pi 4 if needed.
2. Run `./scripts/bootstrap/setup-wizard.sh` on your workstation.
3. The wizard asks for any missing `.env` and `infra/docker/.env.pi4` values.
4. Wizard SSHes to Pi 4, syncs repo + env files, installs dependencies, and starts services.
5. Copy Home Assistant YAML files to Pi 5.
6. Import n8n workflows and bind credentials.

## Validation

- Run `scripts/validate/validate-env.sh`.
- Run `scripts/validate/validate-yaml.sh`.
- Verify n8n UI loads through Nginx.
- Trigger a test Trello webhook and confirm n8n execution.

## Rollback

- Stop stack: `docker compose -f infra/docker/docker-compose.pi4.yml down`.
- Restore n8n backup from `backups/`.
- Revert Home Assistant automation files from version control.
