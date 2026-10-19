#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Pinches as two fingers on a trackpad do: a magnify gesture's events, made in process and
/// handed straight to the test's own window, which sits off every display (ADR 0011).
extension Backend {
    /// Whether the window is ready for a pinch. AppKit routes the events to the window
    /// wherever it sits, so it stays off every display and is always ready.
    static func showsForPinch(_ window: HostWindow) -> Bool {
        true
    }

    /// Pinches the middle of the element to `scale`: a began and a few changed magnify
    /// events, a run loop turn apart, then an ended one unless `holding`, which leaves the
    /// pinch held for `releasePinch`. Whether the element is drawn and the events could be
    /// made.
    static func pinch(to scale: Double, _ node: Node, in window: HostWindow, holding: Bool)
        async -> Bool
    {
        let front = frontWindow(of: window.window)
        guard let point = middle(of: node) else { return false }
        for (phase, amount) in PinchDirection.steps(to: scale) {
            guard await magnify(by: amount, phase, at: point, in: front) else { return false }
        }
        if holding {
            heldPinch = HeldPoint(point: point, window: front)
            return true
        }
        return await magnify(by: 0, .ended, at: point, in: front)
    }

    /// Ends the held pinch where it was held. Whether a pinch was held and its ended event
    /// could be made.
    static func releasePinch(in window: HostWindow) async -> Bool {
        guard let held = heldPinch else { return false }
        heldPinch = nil
        return await magnify(by: 0, .ended, at: held.point, in: held.window)
    }

    /// Lifts the fingers of a pinch still held as its screen closes, so the app's gesture
    /// ends there and the next screen's pinch begins anew.
    static func endHeldPinch() {
        guard let held = heldPinch else { return }
        heldPinch = nil
        let ended = Trackpad.magnify(
            by: 0, .ended, at: held.point, inWindow: held.window.windowNumber,
            height: held.window.frame.height)
        if let ended = ended as? NSEvent { held.window.sendEvent(ended) }
    }

    /// Where a held pinch's fingers rest, and the window they rest in, until it is released
    /// or the screen closes.
    struct HeldPoint {
        let point: CGPoint
        let window: NSWindow
    }

    static var heldPinch: HeldPoint?

    /// Sends one magnify event and waits a run loop turn; whether it could be made.
    private static func magnify(
        by amount: Double, _ phase: GesturePhase, at point: CGPoint, in front: NSWindow
    ) async -> Bool {
        guard
            let event = Trackpad.magnify(
                by: amount, phase, at: point, inWindow: front.windowNumber,
                height: front.frame.height) as? NSEvent
        else { return false }
        front.sendEvent(event)
        await Task.yield()
        return true
    }
}

#endif
