#!/usr/bin/env bash
set -euo pipefail

DEVHUB_ALIAS="${DEVHUB_ALIAS:-apex-json-rpc-devhub}"
PACKAGE_NAME="${PACKAGE_NAME:-ApexJsonRpc}"

if sf package list --target-dev-hub "$DEVHUB_ALIAS" --json | grep -q "\"Name\": \"$PACKAGE_NAME\""; then
  echo "Package $PACKAGE_NAME already exists in Dev Hub $DEVHUB_ALIAS."
  exit 0
fi

sf package create \
  --name "$PACKAGE_NAME" \
  --description "Apex JSON-RPC 2.0 protocol library" \
  --package-type Unlocked \
  --path force-app \
  --target-dev-hub "$DEVHUB_ALIAS"
