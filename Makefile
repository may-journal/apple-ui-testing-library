# Repo tasks. Swift build and test targets join once Package.swift lands.
# Run: make fitness

FITNESS_INSTALL = $(HOME)/.local/share/may-journal/fitness/fitness-install

.PHONY: hooks fitness

# Use the org-synced hooks in .fitness-hooks (see .github/fitness-setup.md once synced).
hooks:
	git config --local core.hooksPath .fitness-hooks

# Run the full fitness suite, as CI does.
fitness:
	"$(FITNESS_INSTALL)" --version latest
