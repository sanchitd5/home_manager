#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
[pi5-ha-notes] Home Assistant import notes

1. Copy files from:
   - home-assistant/automations/
   - home-assistant/helpers/
   - home-assistant/packages/
   - home-assistant/dashboards/

2. Add includes in Home Assistant configuration.yaml if missing:
   automation: !include_dir_merge_list automations
   homeassistant:
     packages: !include_dir_named packages

3. Restart Home Assistant and validate configuration.

4. Ensure placeholders are replaced:
   - vacuum.REPLACE_EUFY_VACUUM
   - sensor.REPLACE_WASHER_POWER
   - sensor.REPLACE_NETWORK_DOWNLOAD

5. Verify Trello-first completion behavior in n8n workflows.
EOF
