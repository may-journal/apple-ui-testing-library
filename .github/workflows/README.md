---
relatedConfigurations: ['../../.fitnessrc.json']
---

# Workflows

GitHub Actions for this repo, all on the Go [fitness-runner](https://github.com/may-journal/fitness-runner) toolchain. The org-settings job in [may-journal/.github](https://github.com/may-journal/.github) syncs the shared callers here by pull request. Locally the synced hooks run the same suite on commit.

## ci

The org-level `Fitness suite` required workflow runs the full suite on every PR. The repo keeps no local ci.yml.

## plan-check

Plans live as GitHub Issues under the `Plan` label, so the file runner never sees them. The synced `plan-check.yml` calls the shared [plan-check-reusable.yml](https://github.com/may-journal/fitness-runner/blob/main/.github/workflows/plan-check-reusable.yml). It validates each Plan issue body and comments once per version.

## close-check and auto-merge-on-ready

The synced `close-check.yml` reopens an issue closed with unchecked checklist items. The synced `auto-merge-on-ready.yml` turns on auto-merge when a draft is marked ready.

## Formats these checks enforce

A plan issue (see the [plan issue template](../ISSUE_TEMPLATE/plan.md)) needs a blockquote pitch, a `## Background` section, and a `## What needs to happen` checklist. It has no other sections.

A pull request description needs a blockquote summary, a `## Background` section, and a `## Changelog` section with at least one bullet. The org `PR check (reusable)` workflow enforces it.
