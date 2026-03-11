#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

get_env_value_from_file() {
  local file="$1"
  local key="$2"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  grep -E "^${key}=" "$file" | head -n1 | cut -d= -f2- || true
}

key_exists_in_file() {
  local file="$1"
  local key="$2"
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  grep -Eq "^${key}=" "$file"
}

needs_user_value() {
  local value="$1"
  if [[ -z "$value" ]]; then
    return 0
  fi
  if [[ "$value" == *"REPLACE_ME"* ]]; then
    return 0
  fi
  if [[ "$value" == *"REPLACE_"* ]]; then
    return 0
  fi
  return 1
}

ensure_file_from_example() {
  local target="$1"
  local example="$2"
  if [[ ! -f "$target" ]]; then
    cp "$example" "$target"
    echo "[wizard] Created $(basename "$target") from example."
  fi
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

env_value() {
  local key="$1"
  local fallback="$2"
  local file="${ROOT_DIR}/.env"
  if [[ -f "$file" ]]; then
    local line
    line="$(grep -E "^${key}=" "$file" | head -n1 || true)"
    if [[ -n "$line" ]]; then
      echo "${line#*=}"
      return
    fi
  fi
  echo "$fallback"
}

prompt_missing_env_values() {
  local target="$1"
  local example="$2"
  local label="$3"
  local tmp_file
  tmp_file="$(mktemp)"

  echo
  echo "[wizard] Let's finish your ${label} configuration."
  echo "[wizard] I'll only ask for values that are empty or still set to REPLACE_ME."

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
      echo "$line" >> "$tmp_file"
      continue
    fi

    if [[ "$line" != *=* ]]; then
      echo "$line" >> "$tmp_file"
      continue
    fi

    local key default current ask_value
    key="${line%%=*}"
    default="${line#*=}"
    current="$(get_env_value_from_file "$target" "$key")"

    if [[ -z "$current" ]]; then
      current="$default"
    fi

    if needs_user_value "$current"; then
      ask_value="$current"
      while true; do
        ask_value="$(prompt_with_default "  Enter value for ${key}" "$ask_value")"
        if needs_user_value "$ask_value"; then
          echo "  [wizard] Please enter a real value (not empty, not REPLACE_ME)."
        else
          break
        fi
      done
      echo "${key}=${ask_value}" >> "$tmp_file"
    else
      echo "${key}=${current}" >> "$tmp_file"
    fi
  done < "$example"

  # Preserve existing non-template keys that are not present in the example file.
  if [[ -f "$target" ]]; then
    local extras_written="false"
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ -z "$line" || "$line" =~ ^[[:space:]]*# || "$line" != *=* ]]; then
        continue
      fi

      local key
      key="${line%%=*}"
      if ! key_exists_in_file "$example" "$key"; then
        if [[ "$extras_written" == "false" ]]; then
          echo >> "$tmp_file"
          echo "# Preserved existing custom keys" >> "$tmp_file"
          extras_written="true"
        fi
        echo "$line" >> "$tmp_file"
      fi
    done < "$target"
  fi

  mv "$tmp_file" "$target"
}

prepare_local_configuration() {
  local env_file="${ROOT_DIR}/.env"
  local env_example="${ROOT_DIR}/.env.example"
  local pi4_env_file="${ROOT_DIR}/infra/docker/.env.pi4"
  local pi4_env_example="${ROOT_DIR}/infra/docker/.env.pi4.example"

  ensure_file_from_example "$env_file" "$env_example"
  ensure_file_from_example "$pi4_env_file" "$pi4_env_example"

  prompt_missing_env_values "$env_file" "$env_example" ".env"
  prompt_missing_env_values "$pi4_env_file" "$pi4_env_example" "infra/docker/.env.pi4"
}

run_ssh() {
  local ssh_target="$1"
  shift
  ssh -tt -o StrictHostKeyChecking=accept-new "$ssh_target" "$@"
}

ensure_remote_bootstrap_tools() {
  local ssh_target="$1"
  echo "[wizard] Installing bootstrap tools on Pi (rsync/curl/git/jq)"
  run_ssh "$ssh_target" "sudo apt-get update && sudo apt-get install -y rsync curl ca-certificates git jq"
}

print_flash_steps() {
  local pi_host="$1"
  local pi_user="$2"
  cat <<EOF

Flash Steps (Required Before SSH Setup)
--------------------------------------
1. Install Raspberry Pi Imager on your laptop.
2. Select OS: Raspberry Pi OS Lite (64-bit).
3. Select your SD card.
4. Open advanced options (gear icon) and set:
   - Hostname: ${pi_host}
   - Enable SSH: Yes
   - Username: ${pi_user}
   - Configure Wi-Fi (if not using Ethernet)
5. Flash, eject SD card, insert into Pi 4B, and power it on.
6. Wait 1-2 minutes, then re-run this wizard.

EOF
}

sync_repo() {
  local ssh_target="$1"
  local install_dir="$2"

  echo "[wizard] Syncing repository to ${ssh_target}:${install_dir}"
  run_ssh "$ssh_target" "mkdir -p '${install_dir}'"

  rsync -az \
    --exclude '.git/' \
    --exclude '.code/' \
    --exclude '.env' \
    --exclude 'infra/docker/.env.pi4' \
    --exclude 'backups/' \
    "${ROOT_DIR}/" "${ssh_target}:${install_dir}/"
}

sync_env_files() {
  local ssh_target="$1"
  local install_dir="$2"
  local local_env="${ROOT_DIR}/.env"
  local local_pi4_env="${ROOT_DIR}/infra/docker/.env.pi4"

  if [[ ! -f "${local_env}" ]]; then
    echo "[wizard] ERROR: ${local_env} is missing. Create it before running the wizard."
    exit 1
  fi

  if grep -Eq "REPLACE_ME|REPLACE_" "${local_env}"; then
    echo "[wizard] ERROR: ${local_env} still contains placeholder values (REPLACE_*)."
    echo "[wizard] Fill real values before continuing."
    exit 1
  fi

  if [[ ! -f "${local_pi4_env}" ]]; then
    echo "[wizard] ERROR: ${local_pi4_env} is missing."
    echo "[wizard] Create it from infra/docker/.env.pi4.example and fill real values first."
    exit 1
  fi

  if grep -Eq "REPLACE_ME|REPLACE_" "${local_pi4_env}"; then
    echo "[wizard] ERROR: ${local_pi4_env} still contains placeholder values (REPLACE_*)."
    echo "[wizard] Fill real values before continuing."
    exit 1
  fi

  echo "[wizard] Syncing configured env files to Pi"
  rsync -az "${local_env}" "${ssh_target}:${install_dir}/.env"
  rsync -az "${local_pi4_env}" "${ssh_target}:${install_dir}/infra/docker/.env.pi4"
}

bootstrap_remote() {
  local ssh_target="$1"
  local install_dir="$2"

  echo "[wizard] Installing base packages on Pi"
  run_ssh "$ssh_target" "sudo apt-get update && sudo apt-get install -y git curl jq ca-certificates rsync"

  echo "[wizard] Installing Docker if missing"
  run_ssh "$ssh_target" "if ! command -v docker >/dev/null 2>&1; then curl -fsSL https://get.docker.com | sudo sh; sudo usermod -aG docker \"\$USER\"; fi"

  echo "[wizard] Ensuring Docker Compose plugin is installed"
  run_ssh "$ssh_target" "if ! docker compose version >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y docker-compose-plugin; fi"

  echo "[wizard] Initializing repository on Pi"
  run_ssh "$ssh_target" "cd '${install_dir}' && chmod +x scripts/bootstrap/*.sh scripts/install/*.sh scripts/validate/*.sh scripts/backup/*.sh ollama/scripts/*.sh"
  run_ssh "$ssh_target" "cd '${install_dir}' && ./scripts/bootstrap/init-repo.sh"

  echo "[wizard] Ensuring Pi4 env file"
  run_ssh "$ssh_target" "cd '${install_dir}' && if [[ ! -f infra/docker/.env.pi4 ]]; then cp infra/docker/.env.pi4.example infra/docker/.env.pi4; fi"

  echo "[wizard] Starting Home Manager services on Pi"
  run_ssh "$ssh_target" "cd '${install_dir}' && ./scripts/install/pi4-setup.sh"
}

main() {
  cat <<'EOF'
Home Manager Setup Wizard (SSH Installer)
=========================================

This wizard connects to Raspberry Pi 4 over SSH and performs setup end-to-end.
Home Assistant is assumed to already be running.

Precondition: Pi 4 must already be flashed and reachable via SSH.
EOF

  prepare_local_configuration

  local default_ha
  default_ha="$(env_value "HA_BASE_URL" "http://192.168.1.3:8123")"

  local flashed

  local ha_url
  ha_url="$(prompt_with_default "Home Assistant URL" "$default_ha")"

  flashed="$(prompt_with_default "Is Pi 4 already flashed with Raspberry Pi OS Lite (64-bit) and SSH enabled? (yes/no)" "no")"
  if [[ "${flashed}" != "yes" ]]; then
    local tmp_host tmp_user
    tmp_host="$(prompt_with_default "Planned Pi 4 host/IP after flash" "home-manager-pi4.local")"
    tmp_user="$(prompt_with_default "Planned Pi 4 user" "pi")"
    print_flash_steps "$tmp_host" "$tmp_user"
    echo "[wizard] Stopping here. Flash Pi 4 first, then run this wizard again."
    exit 0
  fi

  local pi_host pi_user install_dir
  pi_host="$(prompt_with_default "Pi 4 host/IP" "home-manager-pi4.local")"
  pi_user="$(prompt_with_default "Pi 4 user" "pi")"
  install_dir="$(prompt_with_default "Install directory on Pi" "/home/${pi_user}/home_manager")"

  if [[ -z "${pi_host}" ]]; then
    echo "[wizard] Pi host/IP cannot be empty."
    exit 1
  fi

  if [[ -z "${pi_user}" ]]; then
    echo "[wizard] Pi user cannot be empty."
    exit 1
  fi

  if [[ -z "${install_dir}" ]]; then
    echo "[wizard] Install directory cannot be empty."
    exit 1
  fi

  local ssh_target
  ssh_target="${pi_user}@${pi_host}"

  echo
  echo "[wizard] Checking SSH connectivity to ${ssh_target}"
  if ! run_ssh "$ssh_target" "echo connected"; then
    echo "[wizard] Unable to connect over SSH."
    print_flash_steps "$pi_host" "$pi_user"
    exit 1
  fi

  ensure_remote_bootstrap_tools "$ssh_target"

  echo "[wizard] Verifying Home Assistant reachability from Pi"
  run_ssh "$ssh_target" "curl -sS -m 5 '${ha_url}' >/dev/null"

  sync_repo "$ssh_target" "$install_dir"
  sync_env_files "$ssh_target" "$install_dir"
  bootstrap_remote "$ssh_target" "$install_dir"

  cat <<EOF

[wizard] Setup complete.

Next actions (still required):
1. On n8n, import workflows from ${install_dir}/n8n/workflows and bind credentials.
2. On Home Assistant, apply files from home-assistant/ and reload config.
3. Replace any remaining placeholders in automations/entities.
4. Run validation scripts in ${install_dir}/scripts/validate.

Decision locks applied:
- Ingress baseline: infra/nginx/nginx.conf
- Completion authority: Trello-first
- Bin cycle: 2026-03-12 Red+Green, 2026-03-19 Yellow, then weekly alternate
EOF
}

main "$@"
