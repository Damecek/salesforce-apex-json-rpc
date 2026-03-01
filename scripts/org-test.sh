#!/usr/bin/env bash
set -euo pipefail

TARGET_ORG="${TARGET_ORG:-${ORG_ALIAS:-apex-json-rpc-scratch}}"

sf apex run test \
  --target-org "$TARGET_ORG" \
  --test-level RunLocalTests \
  --result-format human \
  --code-coverage \
  --wait 30
