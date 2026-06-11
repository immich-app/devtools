#!/usr/bin/env bash
# Create or delete a single external IdP link (github or gitlab) for a user,
# driven by the terraform_data.idp_link resource (one invocation per user+idp,
# create on add, delete on remove). There is no terraform resource for IdP links.
#
#   idp-link.sh create   # POST   /v2/users/{USER_ID}/links
#   idp-link.sh delete   # DELETE /v2/users/{USER_ID}/links/{IDP_ID}/{EXTERNAL_USER_ID}
#
# Env: ZITADEL_DOMAIN, ZITADEL_TOKEN, USER_ID, IDP_ID, EXTERNAL_USER_ID
#      USER_NAME (create only). Requires curl, jq.

set -euo pipefail

action="${1:?usage: idp-link.sh <create|delete>}"
: "${ZITADEL_DOMAIN:?}" "${ZITADEL_TOKEN:?}" "${USER_ID:?}" "${IDP_ID:?}" "${EXTERNAL_USER_ID:?}"

ZITADEL_DOMAIN="${ZITADEL_DOMAIN#https://}"
ZITADEL_DOMAIN="${ZITADEL_DOMAIN#http://}"
ZITADEL_DOMAIN="${ZITADEL_DOMAIN%/}"
base="https://${ZITADEL_DOMAIN}"

case "$action" in
  create)
    : "${USER_NAME:?}"
    body=$(jq -nc \
      --arg idpId "$IDP_ID" --arg userId "$EXTERNAL_USER_ID" --arg userName "$USER_NAME" \
      '{idpLink: {idpId: $idpId, userId: $userId, userName: $userName}}')
    resp=$(curl -sS -w '\n%{http_code}' -X POST \
      "${base}/v2/users/${USER_ID}/links" \
      -H "Authorization: Bearer ${ZITADEL_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "$body")
    status=$(tail -n1 <<<"$resp"); out=$(sed '$d' <<<"$resp")
    if [[ "$status" -ge 200 && "$status" -lt 300 ]]; then
      echo "linked ${EXTERNAL_USER_ID} (${USER_NAME}) -> user ${USER_ID}"
    elif [[ "$status" -eq 409 ]] || grep -qiE "already exist|already linked|already taken" <<<"$out"; then
      # The external identity is already linked to *some* user. Confirm it's this
      # user — otherwise a wrong id in users.json would silently bind the wrong
      # account. ListIDPLinks returns each link's external id as `userId`.
      links=$(curl -sS -X POST "${base}/v2/users/${USER_ID}/links/_search" \
        -H "Authorization: Bearer ${ZITADEL_TOKEN}" -H "Content-Type: application/json" --data '{}')
      if jq -e --arg idp "$IDP_ID" --arg ext "$EXTERNAL_USER_ID" \
           '.result[]? | select(.idpId == $idp and .userId == $ext)' >/dev/null 2>&1 <<<"$links"; then
        echo "${EXTERNAL_USER_ID} (${USER_NAME}) -> user ${USER_ID} already linked"
      else
        echo "FAILED: external id ${EXTERNAL_USER_ID} (idp ${IDP_ID}) is already linked to a DIFFERENT user, not ${USER_ID}" >&2
        exit 1
      fi
    else
      echo "FAILED create ${EXTERNAL_USER_ID} -> user ${USER_ID}: HTTP ${status} ${out}" >&2
      exit 1
    fi
    ;;
  delete)
    resp=$(curl -sS -w '\n%{http_code}' -X DELETE \
      "${base}/v2/users/${USER_ID}/links/${IDP_ID}/${EXTERNAL_USER_ID}" \
      -H "Authorization: Bearer ${ZITADEL_TOKEN}")
    status=$(tail -n1 <<<"$resp"); out=$(sed '$d' <<<"$resp")
    if [[ "$status" -ge 200 && "$status" -lt 300 ]]; then
      echo "unlinked ${EXTERNAL_USER_ID} from user ${USER_ID}"
    elif [[ "$status" -eq 404 ]]; then
      echo "${EXTERNAL_USER_ID} link on user ${USER_ID} already gone"
    else
      echo "FAILED delete ${EXTERNAL_USER_ID} -> user ${USER_ID}: HTTP ${status} ${out}" >&2
      exit 1
    fi
    ;;
  *)
    echo "unknown action: $action" >&2; exit 1 ;;
esac
