/// What VoiceOver reads on screen, then what is drawn off screen, in reading order.
public struct ScreenReport: Sendable, Equatable, CustomStringConvertible {
    public let onScreen: [Element]
    public let offScreen: [Element]

    public init(onScreen: [Element], offScreen: [Element]) {
        self.onScreen = onScreen
        self.offScreen = offScreen
    }

    /// Whether every read came back empty.
    public var isEmpty: Bool { onScreen.isEmpty && offScreen.isEmpty }

    public var description: String {
        if isEmpty { return "The screen read empty: VoiceOver found nothing." }
        let shown = onScreen.map { "  \($0)" }.joined(separator: "\n")
        let hidden = offScreen.map { "  \($0)" }.joined(separator: "\n")
        return "On screen:\n\(shown)\nDrawn off screen:\n\(hidden.isEmpty ? "  (nothing)" : hidden)"
    }
}

extension ScreenReport {
    /// The report of one read of the tree.
    @MainActor
    init(_ tree: AccessibilityTree) {
        self.init(
            onScreen: tree.elements.filter(\.isOnScreen),
            offScreen: tree.elements.filter { !$0.isOnScreen })
    }
}
