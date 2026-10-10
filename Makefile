# Repo tasks. Run: make fitness, make requirements
#
# requirements: generates the Xcode project from project.yml, then builds and runs both
# hosted test bundles, iOS on the simulator named in SIMULATOR and macOS natively. Each
# platform runs build-for-testing and then test-without-building, so a build failure
# reads apart from a test failure, and no simulator diagnostics are collected, since
# collecting them after a failure takes minutes. All output goes to DERIVED_DATA inside this checkout,
# so parallel checkouts never share build state. Check `xcrun simctl list devices booted`
# first; the target shuts its simulator down when it finishes, even after a failure.

FITNESS_INSTALL = $(HOME)/.local/share/may-journal/fitness/fitness-install
PROJECT = UITestingLibrary.xcodeproj
DERIVED_DATA = .build/DerivedData
SIMULATOR ?= iPhone 17
# The one device of that name on the newest runtime, so the shutdown is never ambiguous.
SIMULATOR_UDID = ${shell xcrun simctl list devices available | grep -F '$(SIMULATOR) (' | tail -1 | sed -E 's/.*[(]([0-9A-F-]+)[)].*/\1/'}
IOS_DESTINATION = platform=iOS Simulator,id=$(SIMULATOR_UDID)
MAC_DESTINATION = platform=macOS
XCODEBUILD = xcodebuild -project $(PROJECT) -derivedDataPath $(DERIVED_DATA)

# $(call run-hosted-tests,scheme,destination): build the scheme for testing, then run it.
run-hosted-tests = $(XCODEBUILD) build-for-testing -scheme $(1) -destination '$(2)' \
	&& $(XCODEBUILD) test-without-building -scheme $(1) -destination '$(2)' \
	-collect-test-diagnostics never

.PHONY: hooks fitness format generate requirements requirements-ios requirements-mac

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
