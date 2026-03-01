#!/usr/bin/env bash
set -euo pipefail

TARGET_ORG="${TARGET_ORG:-${ORG_ALIAS:-apex-json-rpc-scratch}}"

sf project deploy start \
  --target-org "$TARGET_ORG" \
  --source-dir force-app \
  --wait 20
