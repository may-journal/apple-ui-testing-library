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
public enum Key: Sendable, Equatable, CaseIterable {
    /// Enter, the Return key: submits a one-line field, or starts a new line in a field of many.
    case enter
    /// End: moves the cursor to the end of the field. A Mac selects a one-line field's words
    /// as it gains focus, so typing would replace them.
    case end
    /// Home: moves the cursor to the start of the field.
    case home
    /// Escape: runs the shortcut that answers it, such as a sheet's cancel.
    case escape
    /// Tab: moves focus to the next field; with Shift, to the one before.
    case tab
    /// Delete, the Backspace key: deletes the character before the cursor, or the selection.
    case delete
    /// The arrow keys: move the cursor a character left or right, or to the start or end of
    /// a one-line field for up and down. With Shift they select as they move.
    case left, right, up, down
}

/// A key held while another is pressed, as user-event's `{Meta>}` holds one.
public enum Modifier: Sendable, Hashable, CaseIterable {
    case command, shift, option, control
}

/// Which way a person swipes a row: left shows its trailing actions, right its leading ones.
public enum SwipeDirection: Sendable, Equatable {
    case left
    case right
}

/// Which way a person adjusts a slider or stepper: up steps its value up, down steps it down.
public enum AdjustDirection: Sendable, Equatable {
    case up
    case down
}

/// How a drag ended.
enum DragOutcome {
    /// Nothing under the element began a drag.
    case noDrag
    /// The target took nothing the drag carried.
    case refused
    /// The target took the drop.
    case dropped
}

/// A clipboard command a field's Edit menu runs.
enum EditCommand {
    case selectAll, copy, cut, paste
}

/// The platform's accessibility objects, read and driven. UIKit on iOS, AppKit on macOS.
@MainActor
enum Backend {}
