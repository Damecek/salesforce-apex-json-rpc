#!/usr/bin/env bash
set -euo pipefail

DEVHUB_ALIAS="${DEVHUB_ALIAS:-apex-json-rpc-devhub}"
PACKAGE_NAME="${PACKAGE_NAME:-ApexJsonRpc}"
VERSION_NAME="${VERSION_NAME:-v0.1}"
VERSION_DESC="${VERSION_DESC:-JSON-RPC 2.0 Apex core}"

./scripts/validate.sh

sf package version create \
  --package "$PACKAGE_NAME" \
  --version-name "$VERSION_NAME" \
  --version-description "$VERSION_DESC" \
  --code-coverage \
  --installation-key-bypass \
  --target-dev-hub "$DEVHUB_ALIAS" \
  --wait 90
