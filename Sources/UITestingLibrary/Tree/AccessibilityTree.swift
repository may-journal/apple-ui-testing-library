import Foundation

/// One read of the tree, walked depth first as VoiceOver moves. Each platform has its own
/// backend behind this type (ADR 0006).
@MainActor
public struct AccessibilityTree {
    /// The elements a person can reach, in reading order, on and off screen.
    public let elements: [Element]
    let nodes: [Node]

    init(nodes: [Node]) {
        self.nodes = nodes
        elements = nodes.map(\.element)
    }

    /// Reads the screen's window now. The first read turns automation on, and a read that
    /// finds anything feeds the canary.
    public static func read(_ screen: Screen) -> AccessibilityTree {
        Automation.turnOn()
        let tree = Timing.measure(.read) {
            AccessibilityTree(nodes: Backend.nodes(in: screen.window))
        }
        if !tree.nodes.isEmpty { screen.canary = .readElements }
        latest = (ObjectIdentifier(screen), tree)
        // The main queue runs this block only once the caller yields, which is the first
        // chance anything else has to change the screen.
        DispatchQueue.main.async { MainActor.assumeIsolated { latest = nil } }
        return tree
    }

    /// The last read of `screen`, while nothing else has run on the main thread since;
    /// otherwise a new read. A look right after an act reuses the act's settled read.
    static func current(_ screen: Screen) -> AccessibilityTree {
        if let latest, latest.screen == ObjectIdentifier(screen) { return latest.tree }
        return read(screen)
    }

    /// The last read, until the main thread runs anything else.
    private static var latest: (screen: ObjectIdentifier, tree: AccessibilityTree)?

    /// The elements whose middle is inside the window.
    public var onScreen: [Element] { elements.filter(\.isOnScreen) }
}

/// Which way a person scrolls: down shows what lies below, up what lies above.
public enum ScrollDirection: Sendable, Equatable {
    case down
    case up
}

/// The platform's accessibility objects, read and driven. UIKit on iOS, AppKit on macOS.
@MainActor
enum Backend {}
