---
relatedConfigurations: ['.fitnessrc.json']
---

# apple-ui-testing-library

A Swift package, module `UITestingLibrary`, that tests SwiftUI and UIKit apps through the accessibility tree. It brings Testing Library's guiding principles to Apple platforms; see [Platforms](docs/architecture/04-code.md#platforms). See [README.md](README.md) for the pitch.

## Rules

Keep plans in GitHub issues and comments. Never commit plan documents, screenshots, or review artifacts.

- Work from a plan. Non-trivial work follows a `Plan`-labeled [GitHub Issue](https://github.com/may-journal/apple-ui-testing-library/issues?q=label%3APlan).
- Ground changes in the design. Read the [architecture docs](docs/architecture/) and the relevant [ADR](docs/architecture/adr/) first.
- Keep the docs current. A change to the design updates the docs and adds an ADR. Add a CHANGELOG entry for each change.
- Query the way a person perceives the screen: role and label first, visible text next, identifier last ([ADR 0002](docs/architecture/adr/0002-query-priority.md)).
- Wait on a condition with a deadline; never sleep ([ADR 0003](docs/architecture/adr/0003-condition-waits.md)).
- Consumers add the package to test targets only, through XcodeGen `packages:` with `majorVersion: 1`.
