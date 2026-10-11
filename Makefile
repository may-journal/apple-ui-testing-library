# Repo tasks. Run: make fitness, make requirements, make requirements-coverage,
# make requirements-timing
#
# requirements: generates the Xcode project from project.yml, then builds and runs both
# hosted test bundles, both natively on this Mac: the iOS one as Designed for iPad, never
# on a simulator, and the macOS one as an AppKit app. Each platform runs
# build-for-testing and then test-without-building, so a build failure reads apart from a
# test failure, and no diagnostics are collected, since collecting them after a failure
# takes minutes. All output goes to DERIVED_DATA inside this checkout, so parallel
# checkouts never share build state.
#
# requirements-coverage: runs both platforms as requirements does, with code coverage on,
# then prints line coverage of Sources/UITestingLibrary/ per platform and for both together.
# Xcode instruments the package but leaves its static code out of .xcresult coverage, so
# the target reads each run's Coverage.profdata with llvm-cov against the test bundle that
# links the package. Fixtures and tests are left out. Output: per-line hits as .lcov files
# in COVERAGE_DIR, then lines, missed and percent covered for iOS, macOS and both.
#
# requirements-timing: runs both platforms as requirements does, then reads the library's
# signposts from the unified log since the run began. It prints one row per host and phase:
# how many intervals, their total and their mean in milliseconds. Phases nest: an act holds
# its settle, and a settle holds its reads. The log drops a Designed for iPad run's signpost
# names, so the phase comes from each interval's ID; see Sources/UITestingLibrary/Tree/Timing.swift.

FITNESS_INSTALL = $(HOME)/.local/share/may-journal/fitness/fitness-install
PROJECT = UITestingLibrary.xcodeproj
DERIVED_DATA = .build/DerivedData
IOS_DESTINATION = platform=macOS,variant=Designed for iPad
MAC_DESTINATION = platform=macOS
XCODEBUILD = xcodebuild -project $(PROJECT) -derivedDataPath $(DERIVED_DATA)
# YES only under requirements-coverage, which reads PROFILE_DATA after each platform's run.
CODE_COVERAGE ?= NO
PROFILE_DATA = $(DERIVED_DATA)/Build/ProfileData
COVERAGE_DIR = .build/coverage
LIBRARY_SOURCES = Sources/UITestingLibrary
IOS_TEST_BINARY = $(DERIVED_DATA)/Build/Products/Debug-iphoneos/TestHost.app/PlugIns/UITestingLibraryTests.xctest/UITestingLibraryTests
MAC_TEST_BINARY = $(DERIVED_DATA)/Build/Products/Debug/TestHostMac.app/Contents/PlugIns/UITestingLibraryTestsMac.xctest/Contents/MacOS/UITestingLibraryTestsMac

# $(call run-hosted-tests,scheme,destination): build the scheme for testing, then run it.
run-hosted-tests = $(XCODEBUILD) build-for-testing -scheme $(1) -destination '$(2)' \
	-enableCodeCoverage $(CODE_COVERAGE) \
	&& $(XCODEBUILD) test-without-building -scheme $(1) -destination '$(2)' \
	-enableCodeCoverage $(CODE_COVERAGE) -collect-test-diagnostics never

# $(call keep-profile,name): move the one platform's merged profile into COVERAGE_DIR.
keep-profile = mv $(PROFILE_DATA)/*/Coverage.profdata $(COVERAGE_DIR)/$(1).profdata

# $(call export-lines,name,binary): the library's per-line hit counts from one platform's run.
export-lines = xcrun llvm-cov export -format=lcov -instr-profile=$(COVERAGE_DIR)/$(1).profdata \
	$(2) $(LIBRARY_SOURCES) > $(COVERAGE_DIR)/$(1).lcov

# $(call print-coverage,label,lcov files): count each file and line once; a line hit on
# either platform counts as covered.
print-coverage = awk -F'[:,]' '/^SF:/ { file = $$2 } /^DA:/ { line = file ":" $$2; seen[line] = 1; \
	if ($$3 > 0) hit[line] = 1 } END { for (line in seen) { lines++; if (line in hit) covered++ } \
	printf "%-9s %d lines, %d missed, %.2f%% covered\n", "$(1)", lines, lines - covered, 100 * covered / lines }' $(2)

# Signpost phases by the code in the high half of each interval's ID, as Timing.swift sets.
TIMING_PHASES = ["", "render", "read", "settle", "look sees", "look doesNotSee", "look reads", \
	"act taps", "act chooses", "act types", "act scrolls", "act goesBack"]
TIMING_LOG = /usr/bin/log show --signpost --style ndjson \
	--predicate 'subsystem == "org.may-journal.ui-testing-library"'

# Pairs each interval's begin and end by process and ID, then sums them per host and phase.
timing-table = jq -rs --argjson phases '$(TIMING_PHASES)' \
	'map(select(.signpostType == "begin" or .signpostType == "end") | { \
	host: (.processImagePath | split("/") | last), key: [.processID, .signpostID], \
	phase: $$phases[.signpostID / 4294967296 | floor], type: .signpostType, \
	at: ((.timestamp[0:19] | strptime("%Y-%m-%d %H:%M:%S") | mktime) \
	+ (.timestamp[19:26] | tonumber))}) \
	| group_by(.key) | map(select(length == 2) | sort_by(.type) \
	| {host: .[0].host, phase: .[0].phase, ms: (1000 * (.[1].at - .[0].at))}) \
	| group_by([.host, .phase]) \
	| (["host", "phase", "count", "total ms", "mean ms"] | @tsv), (.[] \
	| [.[0].host, .[0].phase, length, (map(.ms) | add | round), \
	((map(.ms) | add) / length * 10 | round / 10)] | @tsv)' | column -t -s "$$(printf '\t')"

.PHONY: hooks fitness format generate requirements requirements-ios requirements-mac \
	requirements-coverage requirements-timing

# Use the org-synced hooks in .fitness-hooks (see .github/fitness-setup.md once synced).
hooks:
	git config --local core.hooksPath .fitness-hooks

# Run the full fitness suite, as CI does.
fitness:
	"$(FITNESS_INSTALL)" --version latest

# Wrap and indent every Swift file with the toolchain's swift-format, per .swift-format.
format:
	xcrun swift-format format --in-place --recursive --configuration .swift-format Sources TestHost Tests

# Generate the Xcode project from project.yml. The .xcodeproj is ignored by git.
generate:
	xcodegen generate --quiet

# Build and run the hosted test bundles on both platforms.
requirements: requirements-ios requirements-mac

# Only the iOS targets sign with a team, so only this run may update provisioning.
requirements-ios: XCODEBUILD += -allowProvisioningUpdates
requirements-ios: generate
	$(call run-hosted-tests,TestHost,$(IOS_DESTINATION))

requirements-mac: generate
	$(call run-hosted-tests,TestHostMac,$(MAC_DESTINATION))

# Run both platforms with coverage on, then print the library's line coverage.
requirements-coverage:
	rm -rf $(COVERAGE_DIR) $(PROFILE_DATA) && mkdir -p $(COVERAGE_DIR)
	$(MAKE) requirements-ios CODE_COVERAGE=YES && $(call keep-profile,ios)
	rm -rf $(PROFILE_DATA)
	$(MAKE) requirements-mac CODE_COVERAGE=YES && $(call keep-profile,mac)
	$(call export-lines,ios,$(IOS_TEST_BINARY))
	$(call export-lines,mac,$(MAC_TEST_BINARY))
	@echo "Line coverage of $(LIBRARY_SOURCES)/ under the requirement tests:"
	@$(call print-coverage,iOS,$(COVERAGE_DIR)/ios.lcov)
	@$(call print-coverage,macOS,$(COVERAGE_DIR)/mac.lcov)
	@$(call print-coverage,Combined,$(COVERAGE_DIR)/ios.lcov $(COVERAGE_DIR)/mac.lcov)

# Run both platforms, then print time per host and phase from the library's signposts.
requirements-timing:
	start="$$(date '+%Y-%m-%d %H:%M:%S')" && $(MAKE) requirements \
	&& $(TIMING_LOG) --start "$$start" | $(timing-table)
