#!/usr/bin/env bash
# Runs the opt-in system requirement tests on a simulator you own, using `make requirements-e2e SIMULATOR_ID=<UDID of a shut-down simulator>`.
# An already booted device is refused, and the simulator is shut down on exit, even after a failure.
set -euo pipefail

: "${PROJECT:?}"
if [[ -z "${SIMULATOR_ID:-}" ]]; then
  echo 'Set SIMULATOR_ID to your shut-down simulator UDID' >&2
  exit 1
fi

destination="platform=iOS Simulator,id=$SIMULATOR_ID"
derived_data=.build/SystemDerivedData

xcrun simctl boot "$SIMULATOR_ID"
trap 'xcrun simctl shutdown "$SIMULATOR_ID"' EXIT HUP INT TERM
xcrun simctl bootstatus "$SIMULATOR_ID" -b
xcodebuild -project "$PROJECT" -derivedDataPath "$derived_data" build-for-testing \
  -scheme SystemTests -destination "$destination" CODE_SIGNING_ALLOWED=NO
xcodebuild -project "$PROJECT" -derivedDataPath "$derived_data" test-without-building \
  -scheme SystemTests -destination "$destination" -parallel-testing-enabled NO \
  -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO
