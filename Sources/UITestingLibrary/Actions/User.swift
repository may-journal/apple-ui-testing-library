/// A person using the app. Every look and act goes through a `User`, waits on a condition
/// up to its deadline, and fails with what VoiceOver reads (ADR 0003).
@MainActor
public struct User {
    /// The screen this user looks at and acts on.
    public let screen: Screen
    /// How long each look or act may take.
    public let wait: Wait

    public init(_ screen: Screen, deadline: Duration = .seconds(5)) {
        self.screen = screen
        wait = Wait(deadline: deadline)
    }

    /// Reads the screen once it settles: every element on screen, in VoiceOver's order.
    public func reads() async -> [Element] {
        await Timing.measure(.reads) { await wait.settle(screen).onScreen }
    }

    /// A failure carrying `message` and what VoiceOver reads now.
    func failure(_ message: String, _ location: SourceLocation) -> Failure {
        Failure(
            message, report: ScreenReport(AccessibilityTree.read(screen)),
            location: location)
    }

    /// Polls until `query` finds exactly one element on screen; the node, or nil at the deadline.
    func find(_ query: Query) async -> Node? {
        var match = Match.none
        _ = await wait.until {
            match = Match(query, in: AccessibilityTree.read(screen))
            return match.node != nil
        }
        return match.node
    }
}
