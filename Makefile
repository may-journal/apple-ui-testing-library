# Repo tasks. Run: make fitness, make requirements, make requirements-coverage
#
# requirements: generates the Xcode project from project.yml, then builds and runs both
# hosted test bundles, iOS on the simulator named in SIMULATOR and macOS natively. Each
# platform runs build-for-testing and then test-without-building, so a build failure
# reads apart from a test failure, and no simulator diagnostics are collected, since
# collecting them after a failure takes minutes. All output goes to DERIVED_DATA inside this checkout,
# so parallel checkouts never share build state. Check `xcrun simctl list devices booted`
# first; the target shuts its simulator down when it finishes, even after a failure.
#
# requirements-coverage: runs both platforms as requirements does, with code coverage on,
# then prints line coverage of Sources/UITestingLibrary/ per platform and for both together.
# Xcode instruments the package but leaves its static code out of .xcresult coverage, so
# the target reads each run's Coverage.profdata with llvm-cov against the test bundle that
# links the package. Fixtures and tests are left out. Output: per-line hits as .lcov files
# in COVERAGE_DIR, then lines, missed and percent covered for iOS, macOS and both.

FITNESS_INSTALL = $(HOME)/.local/share/may-journal/fitness/fitness-install
PROJECT = UITestingLibrary.xcodeproj
DERIVED_DATA = .build/DerivedData
SIMULATOR ?= iPhone 17
# The one device of that name on the newest runtime, so the shutdown is never ambiguous.
SIMULATOR_UDID = ${shell xcrun simctl list devices available | grep -F '$(SIMULATOR) (' | tail -1 | sed -E 's/.*[(]([0-9A-F-]+)[)].*/\1/'}
IOS_DESTINATION = platform=iOS Simulator,id=$(SIMULATOR_UDID)
MAC_DESTINATION = platform=macOS
XCODEBUILD = xcodebuild -project $(PROJECT) -derivedDataPath $(DERIVED_DATA)
# YES only under requirements-coverage, which reads PROFILE_DATA after each platform's run.
CODE_COVERAGE ?= NO
PROFILE_DATA = $(DERIVED_DATA)/Build/ProfileData
COVERAGE_DIR = .build/coverage
LIBRARY_SOURCES = Sources/UITestingLibrary
IOS_TEST_BINARY = $(DERIVED_DATA)/Build/Products/Debug-iphonesimulator/TestHost.app/PlugIns/UITestingLibraryTests.xctest/UITestingLibraryTests
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

.PHONY: hooks fitness format generate requirements requirements-ios requirements-mac \
	requirements-coverage

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

requirements-ios: generate
	$(call run-hosted-tests,TestHost,$(IOS_DESTINATION)); status=$$?; \
		xcrun simctl shutdown "$(SIMULATOR_UDID)"; exit $$status

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
