#if canImport(UIKit)
import UIKit

/// Pinches as two fingers on a Mac's trackpad do, where the iOS app runs on a Mac. The
/// scene's window takes magnify events made in process (ADR 0011).
extension Backend {
    /// Brings the scene's Mac window onto a display, see-through, for a pinch. Returns
    /// whether the window server has it there yet, and true where the app runs on no Mac.
    static func showsForPinch(_ window: HostWindow) -> Bool {
        guard let mac = MacWindow.current else { return true }
        mac.moveOnScreenUnseen()
        return mac.isPlaced
    }

    /// Pinches the middle of the element in or out with a began, a few changed and an ended
    /// magnify event. Returns whether the app runs on a Mac.
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
