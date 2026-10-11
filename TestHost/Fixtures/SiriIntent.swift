import AppIntents

/// Three people form a cycle. The caller is Morgan, so only Riley may be disclosed.
struct FixtureMatchIntent: AppIntent {
    static let title: LocalizedStringResource = "Read my fixture match"

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let matches = ["Morgan": "Riley", "Riley": "Casey", "Casey": "Morgan"]
        let caller = "Morgan"
        guard let recipient = matches[caller] else { throw CocoaError(.coderValueNotFound) }
        return .result(dialog: "\(caller) drew \(recipient).")
    }
}

struct FixtureShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FixtureMatchIntent(),
            phrases: ["Who did I draw in \(.applicationName)"],
            shortTitle: "Read my fixture match", systemImageName: "person")
    }
}
