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

/// The direction a person scrolls: down shows what lies below, up what lies above.
public enum ScrollDirection: Sendable, Equatable {
    case down
    case up
}

/// A key a person presses, named as user-event names it. `{Enter}` and `{End}` go by
/// name, and any other key by the character it types.
public enum Key: Sendable, Hashable, CaseIterable, ExpressibleByExtendedGraphemeClusterLiteral {
    /// The key that types `character`, such as `"3"`. In a field it types the
    /// character, and with Command it runs the app's shortcut.
    case character(Character)
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
    /// The arrow keys move the cursor a character, or to an end of a one-line field.
    /// With Shift they select as they move.
    case left, right, up, down

    /// The keys named beyond the characters they type.
    public static let allCases: [Key] = [
        .enter, .end, .home, .escape, .tab, .delete, .left, .right, .up, .down,
    ]

    /// The key that types the character, as `presses("3")` names it.
    public init(extendedGraphemeClusterLiteral character: Character) {
        self = .character(character)
    }

    public init(unicodeScalarLiteral scalar: Unicode.Scalar) {
        self = .character(Character(scalar))
    }
}

/// A key held while another is pressed, as user-event's `{Meta>}` holds one.
public enum Modifier: Sendable, Hashable, CaseIterable {
    case command, shift, option, control
}

/// The direction a person swipes a row: left shows trailing actions, right leading ones.
public enum SwipeDirection: Sendable, Equatable {
    case left
    case right
}

/// The direction a person adjusts a slider or stepper: up raises its value, down lowers it.
public enum AdjustDirection: Sendable, Equatable {
    case up
    case down
}

/// The direction a person pinches: in draws two fingers together to zoom out; out spreads
/// them apart to zoom in.
public enum PinchDirection: Sendable, Equatable {
    case `in`
    case out

    /// A trackpad's magnify events for the pinch: a began, five steps that shrink
    /// to half or grow by half, and an ended.
    var events: [(GesturePhase, Double)] {
        let step = self == .in ? -0.1 : 0.1
        return [(.began, 0)] + Array(repeating: (.changed, step), count: 5) + [(.ended, 0)]
    }
}

/// How fast a person drags an element: slowly, resting before letting go,
/// or as a flick, letting go while still moving fast.
public enum DragSpeed: Sendable, Equatable {
    case slow
    case flick

    /// The drag's moves after the press, each with its progress along the offset and its
    /// seconds after the press. A slow drag moves 60 times a second and ends with a still
    /// sample that a drag gesture reads as a rest.
    var moves: [(progress: CGFloat, time: TimeInterval)] {
        let count = self == .slow ? 30 : 4
        let interval = self == .slow ? 1.0 / 60 : 0.008
        let path = (1...count).map { (CGFloat($0) / CGFloat(count), Double($0) * interval) }
        return self == .slow ? path + [(1, Double(count) * interval + 0.2)] : path
    }
}

/// How a drag by a distance went.
enum MoveOutcome {
    /// The pointer pressed, moved and let go.
    case moved
    /// No pointer runs in process, as on an iPhone or iPad.
    case noPointer
    /// The pointer found nothing to press: the element draws no frame, or the window has no
    /// view that hears the pointer.
    case unheard
}

/// A trackpad gesture's phase, as Quartz numbers it in a gesture event.
enum GesturePhase: Int64 {
    case began = 1
    case changed = 2
    case ended = 4
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
