#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${ROOT_DIR}/docs/setup-guides"

default_env_value() {
  local key="$1"
  local default="$2"
  if [[ -f "${ROOT_DIR}/.env" ]]; then
    local line
    line="$(grep -E "^${key}=" "${ROOT_DIR}/.env" | head -n1 || true)"
    if [[ -n "${line}" ]]; then
      echo "${line#*=}"
      return
    fi
  fi
  echo "$default"
}

prompt_with_default() {
  local label="$1"
  local default="$2"
  local value
  read -r -p "${label} [${default}]: " value
  if [[ -z "${value}" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

print_header() {
  cat <<'EOF'
Home Manager Setup Wizard
=========================

This wizard is for the case where:
- Raspberry Pi 4B has no OS yet
- Home Assistant is already running

Output: a step-by-step operator guide with ready-to-run commands.
EOF
}

print_flash_notes() {
  local pi_host="$1"
  local pi_user="$2"
  local timezone="$3"
  cat <<EOF

Phase 1: Flash Raspberry Pi 4B (required)
-----------------------------------------
1. Install and open Raspberry Pi Imager on your laptop.
2. Choose OS: "Raspberry Pi OS Lite (64-bit)".
3. Choose your SD card.
4. Open advanced options (gear icon) and set:
   - Hostname: ${pi_host}
   - Enable SSH: yes (public-key authentication recommended)
   - Username: ${pi_user}
   - Timezone: ${timezone}
   - Configure Wi-Fi if using wireless
5. Flash the card and safely eject.
6. Insert card into Pi 4B and boot.

EOF
}

print_bootstrap_commands() {
  local pi_host="$1"
  local pi_user="$2"
  local repo_url="$3"
  cat <<EOF
Phase 2: First Boot and Base Setup
----------------------------------
Wait for the Pi to come online, then run:

ssh ${pi_user}@${pi_host}

On the Pi:

  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install -y git curl jq ca-certificates

Clone repo and bootstrap:

  git clone ${repo_url} /opt/home_manager
  cd /opt/home_manager
  ./scripts/bootstrap/check-prereqs.sh || true
  ./scripts/bootstrap/init-repo.sh

Then configure Pi4 stack:

  cp infra/docker/.env.pi4.example infra/docker/.env.pi4
  nano infra/docker/.env.pi4
  ./scripts/install/pi4-setup.sh

EOF
}

print_integration_steps() {
  local ha_url="$1"
  cat <<EOF
Phase 3: Integrations and Validation
------------------------------------
1. Confirm Home Assistant URL is reachable from Pi 4:
   curl -I ${ha_url}

2. In n8n:
   - Import JSON files from n8n/workflows/
   - Configure Trello, Telegram, Home Assistant credentials
   - Keep workflows disabled until test pass

3. On Home Assistant:
   - Apply files from home-assistant/helpers/, packages/, automations/, dashboards/
   - Restart HA and validate config

4. Run checks in repo:
   - ./scripts/validate/validate-env.sh
   - ./scripts/validate/validate-yaml.sh

5. End-to-end smoke test:
   - Move a Trello card to Doing
   - Confirm vacuum action triggers
   - Confirm Trello-first completion behavior

Important decision locks:
- Ingress baseline: infra/nginx/nginx.conf
- Completion authority: Trello-first
- Bin cycle: 2026-03-12 Red+Green, 2026-03-19 Yellow, then weekly alternate
EOF
}

save_guide() {
  local ha_url="$1"
  local pi_host="$2"
  local pi_user="$3"
  local timezone="$4"
  local repo_url="$5"

  mkdir -p "$OUT_DIR"
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  local file="${OUT_DIR}/pi4-setup-${ts}.md"

  {
    echo "# Home Manager Setup Session"
    echo
    echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo
    echo "## Inputs"
    echo "- Home Assistant URL: ${ha_url}"
    echo "- Pi 4 hostname: ${pi_host}"
    echo "- Pi 4 user: ${pi_user}"
    echo "- Timezone: ${timezone}"
    echo "- Repository URL: ${repo_url}"
    echo
    echo "## Wizard Output"
    print_flash_notes "$pi_host" "$pi_user" "$timezone"
    print_bootstrap_commands "$pi_host" "$pi_user" "$repo_url"
    print_integration_steps "$ha_url"
  } > "$file"

  echo
  echo "Saved setup guide: ${file}"
}

main() {
  print_header

  local default_ha
  local default_tz
  default_ha="$(default_env_value "HA_BASE_URL" "http://192.168.1.3:8123")"
  default_tz="$(default_env_value "TZ" "Australia/Melbourne")"

  local ha_url
  local pi_host
  local pi_user
  local timezone
  local repo_url

  ha_url="$(prompt_with_default "Home Assistant URL" "$default_ha")"
  pi_host="$(prompt_with_default "Pi 4 hostname" "home-manager-pi4.local")"
  pi_user="$(prompt_with_default "Pi 4 username" "pi")"
  timezone="$(prompt_with_default "Timezone" "$default_tz")"
  repo_url="$(prompt_with_default "Git clone URL" "REPLACE_WITH_YOUR_REPO_URL")"

  echo
  echo "========== Generated Guide =========="
  print_flash_notes "$pi_host" "$pi_user" "$timezone"
  print_bootstrap_commands "$pi_host" "$pi_user" "$repo_url"
  print_integration_steps "$ha_url"

  save_guide "$ha_url" "$pi_host" "$pi_user" "$timezone" "$repo_url"
}

main "$@"
