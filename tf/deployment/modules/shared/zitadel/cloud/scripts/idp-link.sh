#!/usr/bin/env bash
# Create or delete a single external IdP link for a user, driven by the
# terraform_data.gitlab_idp_link resource (one invocation per user, create on
# add, delete on remove). There is no terraform resource for IdP links.
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
      echo "linked gitlab ${EXTERNAL_USER_ID} (${USER_NAME}) -> user ${USER_ID}"
    elif [[ "$status" -eq 409 ]] || grep -qiE "already exist|already linked|already taken" <<<"$out"; then
      echo "gitlab ${EXTERNAL_USER_ID} (${USER_NAME}) -> user ${USER_ID} already linked"
    else
      echo "FAILED create gitlab ${EXTERNAL_USER_ID} -> user ${USER_ID}: HTTP ${status} ${out}" >&2
      exit 1
    fi
    ;;
  delete)
    resp=$(curl -sS -w '\n%{http_code}' -X DELETE \
      "${base}/v2/users/${USER_ID}/links/${IDP_ID}/${EXTERNAL_USER_ID}" \
      -H "Authorization: Bearer ${ZITADEL_TOKEN}")
    status=$(tail -n1 <<<"$resp"); out=$(sed '$d' <<<"$resp")
    if [[ "$status" -ge 200 && "$status" -lt 300 ]]; then
      echo "unlinked gitlab ${EXTERNAL_USER_ID} from user ${USER_ID}"
    elif [[ "$status" -eq 404 ]]; then
      echo "gitlab ${EXTERNAL_USER_ID} link on user ${USER_ID} already gone"
    else
      echo "FAILED delete gitlab ${EXTERNAL_USER_ID} -> user ${USER_ID}: HTTP ${status} ${out}" >&2
      exit 1
    fi
    ;;
  *)
    echo "unknown action: $action" >&2; exit 1 ;;
esac
