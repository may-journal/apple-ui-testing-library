#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Pinches as two fingers on a trackpad do, with magnify events made in process and handed
/// to the test's own window (ADR 0011).
extension Backend {
    /// Whether the window is ready for a pinch. AppKit routes the events to the window
    /// wherever it sits, so it stays off every display and is always ready.
    static func showsForPinch(_ window: HostWindow) -> Bool {
        true
    }

    /// Pinches the middle of the element in or out with a began, a few changed and an ended
    /// magnify event. Returns whether the element is drawn and the events could be made.
    static func pinch(_ direction: PinchDirection, _ node: Node, in window: HostWindow) async
        -> Bool
    {
        let front = frontWindow(of: window.window)
        guard let point = middle(of: node) else { return false }
        for (phase, amount) in direction.events {
            guard
                let event = Trackpad.magnify(
                    by: amount, phase, at: point, inWindow: front.windowNumber,
                    height: front.frame.height) as? NSEvent
            else { return false }
            front.sendEvent(event)
            await Task.yield()
        }
        return true
    }
}

#endif
