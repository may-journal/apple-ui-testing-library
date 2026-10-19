#if canImport(UIKit)
import UIKit

/// Drags an element by a distance as a Mac's mouse does, where the iOS app runs on a Mac: the
/// scene's input view takes a press, moves and a release made in process, which UIKit hears
/// as a touch that moves and lifts. The window stays off every display (ADR 0011).
extension Backend {
    /// Presses the middle of the element, moves by `offset` at `speed` and lets go. UIKit
    /// stamps each touch as it arrives, so the view's drag gesture hears a slow drag by its
    /// still last move, and a flick by letting go mid-move. Once pressed, every move and the
    /// release are sent, so no touch stays down.
    static func drag(
        _ node: Node, by offset: CGVector, _ speed: DragSpeed, in window: HostWindow
    ) async -> MoveOutcome {
        guard let mac = MacWindow.current else { return .noPointer }
        let frame = node.element.frame
        func point(_ progress: CGFloat) -> CGPoint {
            mac.point(
                for: frame.offsetBy(dx: offset.dx * progress, dy: offset.dy * progress),
                in: window.window)
        }
        guard mac.press(.leftDown, at: point(0)) else { return .unheard }
        await Task.yield()
        var heard = true
        for move in speed.moves {
            heard = mac.press(.dragged, at: point(move.progress)) && heard
            await Task.yield()
        }
        heard = mac.press(.leftUp, at: point(1)) && heard
        await Task.yield()
        return heard ? .moved : .unheard
    }

    /// Whether a swipe the list could not open must fail rather than flick. UIKit's swipe
    /// controller opens any list row it finds, so a swipe it cannot open always flicks.
    static func refusesSwipe(_ node: Node, in window: HostWindow) -> Bool {
        false
    }
}

extension MacWindow {
    /// Hands a press, move or release at `point` straight to the scene's input view, the owner
    /// of its tracking area, as a key window does. The window is never key, since the app
    /// never comes forward, so it would keep a lone press to make itself key, and the scene
    /// would hear no touch. Whether the input view and event were found.
    func press(_ type: Mouse, at point: CGPoint) -> Bool {
        guard let view = trackingArea?.value(forKey: "owner") as? NSObject,
            let event = mouse(type, at: point, clicks: 1)
        else { return false }
        let selector =
            switch type {
            case .leftDown: "mouseDown:"
            case .dragged: "mouseDragged:"
            default: "mouseUp:"
            }
        view.perform(NSSelectorFromString(selector), with: event)
        return true
    }
}

#endif
