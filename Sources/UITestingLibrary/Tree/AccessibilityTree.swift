import Foundation

/// One read of the tree, walked depth first as VoiceOver moves. Each platform has its own
/// backend behind this type (ADR 0006).
@MainActor
public struct AccessibilityTree {
    let nodes: [Node]

    /// The elements a person can reach, in reading order, on and off screen. Those off
    /// screen are read on first use.
    public var elements: [Element] { nodes.map(\.element) }

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    /// Reads the screen's window now. The first read turns automation on, and a read that
    /// finds anything feeds the canary.
    public static func read(_ screen: Screen) -> AccessibilityTree {
        Automation.turnOn()
        let tree = Timing.measure(.read) {
            AccessibilityTree(nodes: Backend.nodes(in: screen.window))
        }
        if !tree.nodes.isEmpty { screen.canary = .readElements }
        latest = (screen, tree)
        // The main queue runs this block only once the caller yields, which is the first
        // chance anything else has to change the screen.
        DispatchQueue.main.async { MainActor.assumeIsolated { latest = nil } }
        return tree
    }

    /// The last read of `screen`, while nothing else has run on the main thread since;
    /// otherwise a new read. A look right after an act reuses the act's settled read.
    static func current(_ screen: Screen) -> AccessibilityTree {
        if let latest, latest.screen === screen { return latest.tree }
        return read(screen)
    }

    /// The last read, until the main thread runs anything else. It holds its screen, so a
    /// screen rendered after it never takes its place.
    private static var latest: (screen: Screen, tree: AccessibilityTree)?

    /// The elements whose middle is inside the window.
    public var onScreen: [Element] { nodes.filter(\.isOnScreen).map(\.element) }
}

/// Which way a person scrolls: down shows what lies below, up what lies above.
public enum ScrollDirection: Sendable, Equatable {
    case down
    case up
}

/// A key a person presses beyond typing text, in the field being edited, as user-event's
/// `{Enter}` and `{End}` name them.
public enum Key: Sendable, Equatable {
    /// Enter, the Return key: submits a one-line field, or starts a new line in a field of many.
    case enter
    /// End: moves the cursor to the end of the field. A Mac selects a one-line field's words
    /// as it gains focus, so typing would replace them.
    case end
}

/// The platform's accessibility objects, read and driven. UIKit on iOS, AppKit on macOS.
@MainActor
enum Backend {}
