#if canImport(UIKit)
import UIKit

/// Drags an element by a distance as a Mac's mouse does, where the iOS app runs on a Mac: the
/// scene's input view takes a press, moves and a release made in process, which UIKit hears
/// as a touch that moves and lifts. The window stays off every display (ADR 0011).
extension Backend {
    /// Presses the middle of the element, moves by `offset` at `speed` and lets go. UIKit
    /// stamps each touch as it arrives, so the view's drag gesture hears a slow drag by its
    /// rest before letting go, and a flick by letting go mid-move. Whether the app runs on a
    /// Mac and its scene's input view was found.
    static func drag(
        _ node: Node, by offset: CGVector, _ speed: DragSpeed, in window: HostWindow
    ) async -> Bool {
        guard let mac = MacWindow.current else { return false }
        let frame = node.element.frame
        func point(_ progress: CGFloat) -> CGPoint {
            mac.point(
                for: frame.offsetBy(dx: offset.dx * progress, dy: offset.dy * progress),
                in: window.window)
        }
        guard mac.press(.leftDown, at: point(0)) else { return false }
        await Task.yield()
        for move in speed.moves {
            mac.press(.dragged, at: point(move.progress))
            await Task.yield()
        }
        mac.press(.leftUp, at: point(1))
        await Task.yield()
        return true
    }

    /// Whether the element sits in a list's row, as a collection view's item under its middle.
    static func isListRow(_ node: Node, in window: HostWindow) -> Bool {
        guard let object = node.object as? NSObject else { return false }
        let point = window.window.convert(object.accessibilityActivationPoint, from: nil)
        return views(at: point, in: window.window).contains { view in
            guard let list = view as? UICollectionView else { return false }
            return list.indexPathForItem(at: list.convert(point, from: window.window)) != nil
        }
    }
}

extension MacWindow {
    /// Hands a press, move or release at `point` straight to the scene's input view, the owner
    /// of its tracking area, as a key window does. The window is never key, since the app
    /// never comes forward, so it would keep a lone press to make itself key, and the scene
    /// would hear no touch. Whether the input view and event were found.
    @discardableResult
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
