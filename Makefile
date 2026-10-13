# Repo tasks. Run: make fitness, make requirements, make requirements-coverage,
# make requirements-timing, and opt in to make requirements-e2e
#
# How the requirements targets work: docs/architecture/04-code.md, Tests. Their logic lives
# in scripts/, so this file holds only variables and calls.

FITNESS_INSTALL = $(HOME)/.local/share/may-journal/fitness/fitness-install
PROJECT = UITestingLibrary.xcodeproj
DERIVED_DATA = .build/DerivedData
IOS_DESTINATION = platform=macOS,variant=Designed for iPad
MAC_DESTINATION = platform=macOS
XCODEBUILD = xcodebuild -project $(PROJECT) -derivedDataPath $(DERIVED_DATA)
# YES only under requirements-coverage, whose script reads PROFILE_DATA after each run.
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

export PROJECT SIMULATOR_ID COVERAGE_DIR PROFILE_DATA LIBRARY_SOURCES IOS_TEST_BINARY MAC_TEST_BINARY

.PHONY: hooks fitness format generate requirements requirements-ios requirements-mac \
	requirements-coverage requirements-timing requirements-e2e

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

# Opt-in system tests on a shut-down simulator you own: make requirements-e2e SIMULATOR_ID=<UDID>.
requirements-e2e: generate
	scripts/requirements-e2e.sh

# Run both platforms with coverage on, then print the library's line coverage.
requirements-coverage:
	scripts/requirements-coverage.sh

# Run both platforms, then print time per host and phase, even after a failing test.
requirements-timing:
	scripts/requirements-timing.sh
