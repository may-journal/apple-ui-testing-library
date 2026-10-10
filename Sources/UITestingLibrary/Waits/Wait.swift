/// Polls a condition until it holds or the deadline passes (ADR 0003).
public struct Wait: Sendable, Equatable {
    /// How long a look or act may take before it fails with the screen report.
    public let deadline: Duration
    /// How long the tree rests between reads.
    static let pause = Duration.milliseconds(50)

    public init(deadline: Duration = .seconds(5)) {
        self.deadline = deadline
    }

    /// Polls `condition` until it holds or the deadline passes; whether it held.
    @MainActor
    func until(_ condition: @MainActor () -> Bool) async -> Bool {
        let end = ContinuousClock.now + deadline
        while ContinuousClock.now < end {
            if condition() { return true }
            try? await Task.sleep(for: Self.pause)
        }
        return condition()
    }

    /// Reads the screen until two reads a pause apart match, then returns the last. The pause
    /// lets a change the act queued land first, such as a Mac sheet's window attaching.
    @MainActor
    func settle(_ screen: Screen) async -> AccessibilityTree {
        var last = AccessibilityTree.read(screen)
        try? await Task.sleep(for: Self.pause)
        _ = await until {
            let now = AccessibilityTree.read(screen)
            defer { last = now }
            return now.elements == last.elements
        }
        return last
    }
}
