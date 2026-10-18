#if canImport(UIKit)
import UIKit

/// Pinches as two fingers on a Mac's trackpad do, where the iOS app runs on a Mac: the
/// scene's Mac window takes magnify events made in process, which UIKit hears as a pinch
/// under the pointer (ADR 0011).
extension Backend {
    /// Brings the scene's Mac window onto a display, see-through, for a pinch: the scene
    /// hears the pointer only where a display shows it. Whether AppKit counts the window as
    /// shown yet; a window long off every display hears no pinch until it does. True where
    /// the app runs on no Mac, as there is nothing to show and the pinch fails at once.
    static func showsForPinch(_ window: HostWindow) -> Bool {
        guard let mac = MacWindow.current else { return true }
        mac.moveOnScreenUnseen()
        return mac.isShown
    }

    /// Pinches the middle of the element in or out: the pointer moves over it, then a began,
    /// a few changed and an ended magnify event follow, a run loop turn apart. The window
    /// then goes back off every display, unless a hover holds it. Whether the app runs on a
    /// Mac.
    static func pinch(_ direction: PinchDirection, _ node: Node, in window: HostWindow) async
        -> Bool
    {
        guard let mac = MacWindow.current else { return false }
        defer { if !isHovering { mac.moveOffScreen() } }
        // The input view's tracking area is the one drawn on the display, so read it there.
        guard let area = mac.trackingArea else { return false }
        let point = mac.point(for: node.element.frame, in: window.window)
        let entering = !isHovering
        if entering { mac.send(mac.crossing(.entered, area, at: point)) }
        mac.send(mac.mouse(.moved, at: point, clicks: 0))
        // The scene places the pointer a run loop turn after it moves.
        await Task.yield()
        let pinched = await magnify(direction, at: point, in: mac)
        if entering { mac.send(mac.crossing(.exited, area, at: point)) }
        return pinched
    }

    /// Sends the pinch's magnify events, a run loop turn apart; whether each could be made.
    private static func magnify(_ direction: PinchDirection, at point: CGPoint, in mac: MacWindow)
        async -> Bool
    {
        for (phase, amount) in direction.events {
            guard let event = mac.magnify(by: amount, phase, at: point) else { return false }
            mac.send(event)
            await Task.yield()
        }
        return true
    }
}

#endif
