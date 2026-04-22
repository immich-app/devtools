#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
token="$(jq -r '.token' <<<"$input")"
server_id="$(jq -r '.server_id' <<<"$input")"
user_ids_csv="$(jq -r '.user_ids' <<<"$input")"

members=()

if [[ -n "$user_ids_csv" ]]; then
  IFS=',' read -ra user_ids <<<"$user_ids_csv"
  for uid in "${user_ids[@]}"; do
    [[ -z "$uid" ]] && continue

    while :; do
      headers_file="$(mktemp)"
      status="$(curl -sS -o /dev/null -D "$headers_file" -w '%{http_code}' \
        -H "Authorization: Bot $token" \
        "https://discord.com/api/v10/guilds/$server_id/members/$uid" || echo '000')"

      case "$status" in
        200)
          members+=("$uid")
          rm -f "$headers_file"
          break
          ;;
        404)
          rm -f "$headers_file"
          break
          ;;
        429)
          reset="$(awk 'BEGIN{IGNORECASE=1} /^X-RateLimit-Reset-After:/ {print $2}' "$headers_file" | tr -d '\r')"
          rm -f "$headers_file"
          sleep "${reset:-5}"
          ;;
        *)
          echo "uid=$uid returned status=$status" >&2
          rm -f "$headers_file"
          break
          ;;
      esac
    done
  done
fi

if [[ ${#members[@]} -eq 0 ]]; then
  member_ids_json='[]'
else
  member_ids_json="$(printf '%s\n' "${members[@]}" | jq -R . | jq -sc .)"
fi
jq -nc --arg member_ids "$member_ids_json" '{member_ids: $member_ids}'
