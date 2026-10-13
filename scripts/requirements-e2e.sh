#!/usr/bin/env bash
# Run the opt-in system requirement tests on a simulator you own, then shut it down.
# Usage: make requirements-e2e SIMULATOR_ID=<UDID of a shut-down simulator>.
# Inputs: SIMULATOR_ID and PROJECT, from the Makefile's environment. An already booted
#   device is refused, since only a successful boot here grants this script its cleanup.
# Outputs: build products and XCTest results in .build/SystemDerivedData; the exit status
#   of the run. The simulator is shut down on exit, even after a failure.
# How it works: docs/architecture/04-code.md, Tests.
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
