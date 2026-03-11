# Troubleshooting

## n8n not reachable

- Check `docker ps` for `n8n` and `nginx` containers.
- Validate `infra/nginx/nginx.conf` syntax.
- Check port collisions on 80/443/5678.

## Home Assistant call fails

- Verify `HA_BASE_URL` and `HA_LONG_LIVED_TOKEN`.
- Confirm placeholder entity IDs are replaced.

## Trello card not created

- Verify Trello key/token and list IDs.
- Confirm webhook payload includes expected list transition fields.

## Bin type mismatch

- Confirm anchor date logic:
  - Thursday, March 12, 2026 => `Red + Green Bin`
- Verify local timezone (`TZ`) on Pi 4.

## ESPHome display blank

- Confirm Wi-Fi credentials.
- Confirm Home Assistant API connectivity.
- Rebuild and flash with valid board pins for your CYD hardware revision.
