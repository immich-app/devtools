#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
PEM_VALUE=$(echo "$INPUT" | jq -r '.pem_value')

if [ -z "$PEM_VALUE" ] || [ "$PEM_VALUE" = "CHANGE_ME" ]; then
  jq -n '{"pkcs1": "CHANGE_ME", "pkcs8": "CHANGE_ME"}'
else
  PKCS1=$(printf "%b" "$PEM_VALUE")

  # Validate PKCS#1 format
  echo "$PKCS1" | openssl rsa -check -noout >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Input PEM does not appear to be valid PKCS#1 format" >&2
    exit 1
  fi

  # Convert to PKCS#8
  PKCS8=$(echo "$PKCS1" | openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$PKCS8" ]; then
    echo "PKCS8 conversion failed" >&2
    exit 1
  fi

  jq -n --arg pkcs1 "$PKCS1
" --arg pkcs8 "$PKCS8
" '{"pkcs1": $pkcs1, "pkcs8": $pkcs8}'
fi
