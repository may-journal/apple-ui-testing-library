/// Whether any read of a screen found an element (ADR 0004).
public enum Canary: Sendable, Equatable {
    /// At least one read found elements.
    case readElements
    /// Every read came back empty, so automation is off or the app exposes nothing.
    case readNothing

    /// Fails a screen that was closed without ever reading an element.
    @MainActor
    static func check(_ screen: Screen, location: SourceLocation) throws {
        guard screen.canary == .readNothing else { return }
        throw Failure(
            "VoiceOver read nothing while the screen was open: "
                + "automation is off or the app exposes nothing",
            report: ScreenReport(onScreen: [], offScreen: []),
            location: location)
    }
}
