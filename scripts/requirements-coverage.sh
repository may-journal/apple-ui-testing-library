#!/usr/bin/env bash
# Run both requirement suites with code coverage on, then print the library's line coverage.
# Usage: make requirements-coverage (the Makefile exports the inputs and calls this script).
# Inputs, all from the Makefile's environment: COVERAGE_DIR, PROFILE_DATA, LIBRARY_SOURCES,
#   IOS_TEST_BINARY, MAC_TEST_BINARY.
# Outputs: ios.lcov and mac.lcov in COVERAGE_DIR, then lines, missed and percent covered for
#   iOS, macOS and both on stdout. A line hit on either platform counts as covered.
# How it works: docs/architecture/04-code.md, Tests.
set -euo pipefail

: "${COVERAGE_DIR:?}" "${PROFILE_DATA:?}" "${LIBRARY_SOURCES:?}" "${IOS_TEST_BINARY:?}" "${MAC_TEST_BINARY:?}"

# keep_profile name: move one platform's merged profile into COVERAGE_DIR.
keep_profile() {
  mv "$PROFILE_DATA"/*/Coverage.profdata "$COVERAGE_DIR/$1.profdata"
}

# export_lines name binary: the library's per-line hit counts from one platform's run.
export_lines() {
  xcrun llvm-cov export -format=lcov -instr-profile="$COVERAGE_DIR/$1.profdata" \
    "$2" "$LIBRARY_SOURCES" >"$COVERAGE_DIR/$1.lcov"
}

# print_coverage label lcov-files...: count each file and line once.
print_coverage() {
  local label="$1"
  shift
  awk -F'[:,]' -v label="$label" '
    /^SF:/ { file = $2 }
    /^DA:/ { line = file ":" $2; seen[line] = 1; if ($3 > 0) hit[line] = 1 }
    END {
      for (line in seen) { lines++; if (line in hit) covered++ }
      printf "%-9s %d lines, %d missed, %.2f%% covered\n", label, lines, lines - covered, 100 * covered / lines
    }' "$@"
}

rm -rf "$COVERAGE_DIR" "$PROFILE_DATA"
mkdir -p "$COVERAGE_DIR"
make requirements-ios CODE_COVERAGE=YES
keep_profile ios
rm -rf "$PROFILE_DATA"
make requirements-mac CODE_COVERAGE=YES
keep_profile mac
export_lines ios "$IOS_TEST_BINARY"
export_lines mac "$MAC_TEST_BINARY"

echo "Line coverage of $LIBRARY_SOURCES/ under the requirement tests:"
print_coverage iOS "$COVERAGE_DIR/ios.lcov"
print_coverage macOS "$COVERAGE_DIR/mac.lcov"
print_coverage Combined "$COVERAGE_DIR/ios.lcov" "$COVERAGE_DIR/mac.lcov"
