#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Drags an element by a distance as a mouse does: a press, moves and a release, made in
/// process and handed straight to the test's own window, which sits off every display
/// (ADR 0011).
extension Backend {
    /// Presses the middle of the element, moves by `offset` at `speed` and lets go. Each event
    /// is stamped as a mouse at that speed would stamp it, so the view's drag gesture hears
    /// the speed as well as the distance. Whether the element is drawn.
    static func drag(
        _ node: Node, by offset: CGVector, _ speed: DragSpeed, in window: HostWindow
    ) async -> Bool {
        let front = frontWindow(of: window.window)
        guard let start = middle(of: node) else { return false }
        // The window counts up from its bottom; the offset counts down, as SwiftUI does.
        func point(_ progress: CGFloat) -> CGPoint {
            CGPoint(x: start.x + offset.dx * progress, y: start.y - offset.dy * progress)
        }
        let pressed = ProcessInfo.processInfo.systemUptime
        send(mouse(.leftMouseDown, at: point(0), clicks: 1, in: front, time: pressed), to: front)
        await Task.yield()
        for move in speed.moves {
            send(
                mouse(
                    .leftMouseDragged, at: point(move.progress), clicks: 1, in: front,
                    time: pressed + move.time), to: front)
            await Task.yield()
        }
        let released = pressed + (speed.moves.last?.time ?? 0)
        send(mouse(.leftMouseUp, at: point(1), clicks: 1, in: front, time: released), to: front)
        await Task.yield()
        return true
    }

    /// Whether the element sits in a list's row, as a table's row view holding its middle.
    static func isListRow(_ node: Node, in window: HostWindow) -> Bool {
        var view = hitView(at: node.element.frame, in: frontWindow(of: window.window))
        while let current = view {
            if current is NSTableRowView { return true }
            view = current.superview
        }
        return false
    }
}

#endif
