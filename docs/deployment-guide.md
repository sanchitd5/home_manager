# Deployment Guide

## Purpose

Deploy the scaffold to Pi 4 and Pi 5 with minimal operator ambiguity.

## Prerequisites

- SSH access to both Raspberry Pis
- Docker on Pi 4
- Home Assistant running on Pi 5
- Trello and Telegram credentials ready

## Steps

1. If Pi 4 is unflashed, run `./scripts/bootstrap/setup-wizard.sh` on your workstation and follow the generated flash + bootstrap guide.
2. Clone repository onto Pi 4.
3. Configure `.env` and `infra/docker/.env.pi4`.
4. Run `scripts/bootstrap/check-prereqs.sh`.
5. Run `scripts/bootstrap/init-repo.sh`.
6. Run `scripts/install/pi4-setup.sh`.
7. Copy Home Assistant YAML files to Pi 5.
8. Import n8n workflows and bind credentials.

## Validation

- Run `scripts/validate/validate-env.sh`.
- Run `scripts/validate/validate-yaml.sh`.
- Verify n8n UI loads through Nginx.
- Trigger a test Trello webhook and confirm n8n execution.

## Rollback

- Stop stack: `docker compose -f infra/docker/docker-compose.pi4.yml down`.
- Restore n8n backup from `backups/`.
- Revert Home Assistant automation files from version control.
