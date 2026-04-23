#!/usr/bin/env bash
# Push hosted-login-UI (v2) custom translations to a ZITADEL instance.
#
# Required env vars:
#   ZITADEL_DOMAIN        instance domain, no scheme (e.g. auth.futo.org)
#   ZITADEL_PROFILE_JSON  JWT profile JSON for a machine user with
#                         iam.policy.write (i.e. IAM_OWNER)
#   TRANSLATIONS_FILE     path to a JSON file with the override keys
#                         (deep-merged over bundled defaults by the v2 UI)
#   LOCALE                BCP 47 language tag (e.g. "en")
#
# Requires: curl, jq, openssl (all standard on a dev box).

set -euo pipefail

: "${ZITADEL_DOMAIN:?ZITADEL_DOMAIN is required}"
: "${ZITADEL_PROFILE_JSON:?ZITADEL_PROFILE_JSON is required}"
: "${TRANSLATIONS_FILE:?TRANSLATIONS_FILE is required}"
: "${LOCALE:?LOCALE is required}"

# Tolerate values that include a scheme and/or trailing slash.
ZITADEL_DOMAIN="${ZITADEL_DOMAIN#https://}"
ZITADEL_DOMAIN="${ZITADEL_DOMAIN#http://}"
ZITADEL_DOMAIN="${ZITADEL_DOMAIN%/}"

if [[ ! -f "$TRANSLATIONS_FILE" ]]; then
  echo "translations file not found: $TRANSLATIONS_FILE" >&2
  exit 1
fi

# -- base64url helpers ------------------------------------------------------
b64url() {
  # Stream in -> base64url out (no padding). `tr -d '\n'` instead of GNU `base64 -w0`
  # so this works on macOS/BSD base64 too.
  base64 | tr -d '\n' | tr '+/' '-_' | tr -d '='
}

# -- parse profile JSON -----------------------------------------------------
profile_tmp=""; key_tmp=""; signing_tmp=""; sig_tmp=""
trap 'rm -f "$profile_tmp" "$key_tmp" "$signing_tmp" "$sig_tmp"' EXIT
profile_tmp=$(mktemp)
echo "$ZITADEL_PROFILE_JSON" >"$profile_tmp"

key_id=$(jq -r '.keyId' "$profile_tmp")
user_id=$(jq -r '.userId' "$profile_tmp")
if [[ -z "$key_id" || "$key_id" == "null" || -z "$user_id" || "$user_id" == "null" ]]; then
  echo "ZITADEL_PROFILE_JSON is missing keyId or userId" >&2
  exit 1
fi

key_tmp=$(mktemp)
jq -r '.key' "$profile_tmp" >"$key_tmp"

# -- build + sign JWT assertion --------------------------------------------
now=$(date +%s)
exp=$((now + 60))
issuer="https://${ZITADEL_DOMAIN}"

header=$(printf '{"alg":"RS256","typ":"JWT","kid":"%s"}' "$key_id" | b64url)
payload=$(jq -cn \
  --arg iss "$user_id" \
  --arg sub "$user_id" \
  --arg aud "$issuer" \
  --argjson iat "$now" \
  --argjson exp "$exp" \
  '{iss:$iss, sub:$sub, aud:$aud, iat:$iat, exp:$exp}' | b64url)

signing_tmp=$(mktemp)
printf '%s.%s' "$header" "$payload" >"$signing_tmp"

sig_tmp=$(mktemp)
openssl dgst -sha256 -sign "$key_tmp" -out "$sig_tmp" "$signing_tmp"
signature=$(b64url <"$sig_tmp")

assertion="${header}.${payload}.${signature}"

# -- exchange for access token ---------------------------------------------
token_response=$(curl -sS -X POST "${issuer}/oauth/v2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" \
  --data-urlencode "scope=openid urn:zitadel:iam:org:project:id:zitadel:aud" \
  --data-urlencode "assertion=${assertion}")

access_token=$(jq -r '.access_token // empty' <<<"$token_response")
if [[ -z "$access_token" ]]; then
  echo "token exchange failed:" >&2
  echo "$token_response" >&2
  exit 1
fi

# -- PUT translations -------------------------------------------------------
body=$(jq -c --arg locale "$LOCALE" \
  '{instance: true, locale: $locale, translations: .}' \
  "$TRANSLATIONS_FILE")

response=$(curl -sS -w '\n%{http_code}' -X PUT \
  "${issuer}/v2/settings/hosted_login_translation" \
  -H "Authorization: Bearer ${access_token}" \
  -H "Content-Type: application/json" \
  --data "$body")

status=$(tail -n1 <<<"$response")
body_out=$(sed '$d' <<<"$response")

if [[ "$status" -lt 200 || "$status" -ge 300 ]]; then
  echo "PUT /v2/settings/hosted_login_translation failed (HTTP $status):" >&2
  echo "$body_out" >&2
  exit 1
fi

echo "hosted login translations updated for locale=$LOCALE (HTTP $status)"
