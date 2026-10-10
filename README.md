---
relatedConfigurations: ['.fitnessrc.json']
---

# Apple UI Testing Library

A Swift package for testing SwiftUI, UIKit and AppKit apps the way people use them, on iOS and macOS. Its module is `UITestingLibrary`; see [Platforms](docs/architecture/04-code.md#platforms) for supported versions.

It ports [Testing Library](https://testing-library.com/)'s [guiding principles](https://testing-library.com/docs/guiding-principles/) to Apple platforms, credited to Kent C. Dodds and its maintainers. Tests read the screen as VoiceOver does and act through what VoiceOver offers.

## Use

Add the package to a test target hosted by your app, then render your root and act as a person would:

```swift
@MainActor @Test func testSaving() async throws {
    let screen = try Screen.render { AppRoot() }
    let user = User(screen)
    try await user.types("Milk")
    try await user.taps(.button("Save"))
    try await user.sees(.text("Saved"))
    try screen.close()
}
```

The [usage guide](docs/usage.md) covers setup, every query, action and wait, and failures. A failed look or act throws a `Failure` naming the test's line and listing what VoiceOver reads. This repo's own hosts are built the same way: `make requirements` generates the Xcode project from `project.yml` and runs the iOS and Mac bundles.

## System menus

Some controls open system UI that no accessibility action reaches in-process, such as a share sheet or a `Menu`. Tapping one fails saying so. Cover that screen with one XCUITest smoke test, which drives the app by touch. Keep the rest of the suite in-process.

## Docs

- [docs/usage.md](docs/usage.md) — the usage guide
- [docs/architecture/](docs/architecture/) — the design ([kickoff questions](docs/architecture/00-kickoff-questions.md))
- [Plans](https://github.com/may-journal/apple-ui-testing-library/issues?q=label%3APlan) — work in flight, tracked as GitHub Issues

## License

MIT. See [LICENSE](LICENSE).
