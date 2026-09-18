#!/bin/sh
set -eu

TEMPLATE_FILE=/etc/xray/config.template.json
CONFIG_FILE=/tmp/xray-config.json

is_valid_uuid() {
  [ "${#1}" -eq 36 ] &&
    printf '%s' "$1" | grep -Eq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$'
}

cp "$TEMPLATE_FILE" "$CONFIG_FILE"

DEFAULT_IUID=$(sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_FILE" | head -n 1)

if [ -z "$DEFAULT_IUID" ] || ! is_valid_uuid "$DEFAULT_IUID"; then
  echo "UUID par défaut absent ou invalide dans $TEMPLATE_FILE" >&2
  exit 1
fi

SELECTED_IUID="$DEFAULT_IUID"

if [ -n "${IUID:-}" ]; then
  if is_valid_uuid "$IUID"; then
    SELECTED_IUID="$IUID"
  else
    echo "Avertissement : IUID invalide ; utilisation de l'UUID par défaut." >&2
  fi
fi

sed -i "s|\"id\"[[:space:]]*:[[:space:]]*\"$DEFAULT_IUID\"|\"id\": \"$SELECTED_IUID\"|" "$CONFIG_FILE"

exec xray run -config "$CONFIG_FILE"
