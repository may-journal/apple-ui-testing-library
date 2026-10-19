#if canImport(UIKit)
import UIKit

/// Pinches as two fingers on a Mac's trackpad do, where the iOS app runs on a Mac: the
/// scene's Mac window takes magnify events made in process, which UIKit hears as a pinch
/// under the pointer (ADR 0011).
extension Backend {
    /// Brings the scene's Mac window onto a display, see-through, for a pinch: the scene
    /// hears the pointer only where a display shows it. Whether the window server has it
    /// there yet; the scene hears no pinch until it does. True where the app runs on no Mac,
    /// as there is nothing to show and the pinch fails at once.
    static func showsForPinch(_ window: HostWindow) -> Bool {
        guard let mac = MacWindow.current else { return true }
        mac.moveOnScreenUnseen()
        return mac.isPlaced
    }

    /// Pinches the middle of the element to `scale`: the pointer moves over it, then a began
    /// and changed magnify events follow, a run loop turn apart, steered by a gauge to
    /// `scale`, and an ended one unless `holding`. A held pinch keeps the pointer and the
    /// window where they are until `releasePinch`; otherwise the window goes back off every
    /// display, unless a hover holds it. Whether the app runs on a Mac.
    static func pinch(to scale: Double, _ node: Node, in window: HostWindow, holding: Bool)
        async -> Bool
    {
        guard let mac = MacWindow.current else { return false }
        guard let held = await placesPointer(over: node, in: window, mac) else {
            finishPinch(in: mac)
            return false
        }
        guard await magnify([(.began, 0)], at: held.point, in: mac),
            await steer(to: scale, at: held.point, in: mac, by: held.gauge)
        else {
            lift(held, in: mac)
            return false
        }
        if holding {
            heldPinch = held
            return true
        }
        let ended = await magnify([(.ended, 0)], at: held.point, in: mac)
        lift(held, in: mac)
        return ended
    }

    /// Moves the pointer over the middle of the element, into the window first unless a
    /// hover has it there, and puts a gauge on the window. Nil if the window draws no input
    /// view's tracking area.
    private static func placesPointer(over node: Node, in window: HostWindow, _ mac: MacWindow)
        async
        -> HeldPoint?
    {
        // The input view's tracking area is the one drawn on the display, so read it there.
        guard let area = mac.trackingArea else { return nil }
        let point = mac.point(for: node.element.frame, in: window.window)
        let entering = !isHovering
        if entering { mac.send(mac.crossing(.entered, area, at: point)) }
        mac.send(mac.mouse(.moved, at: point, clicks: 0))
        // The scene places the pointer a run loop turn after it moves.
        await Task.yield()
        return HeldPoint(point: point, entered: entering, gauge: PinchGauge(on: window.window))
    }

    /// Ends the held pinch where it was held, then lets the pointer and the window go as a
    /// whole pinch does. Whether a pinch was held and its ended event could be made.
    static func releasePinch(in window: HostWindow) async -> Bool {
        guard let held = heldPinch, let mac = MacWindow.current else { return false }
        heldPinch = nil
        let ended = await magnify([(.ended, 0)], at: held.point, in: mac)
        lift(held, in: mac)
        return ended
    }

    /// Lifts the fingers of a pinch still held as its screen closes, so the app's gesture
    /// ends there and the next screen's pinch begins anew.
    static func endHeldPinch() {
        guard let held = heldPinch else { return }
        heldPinch = nil
        guard let mac = MacWindow.current else { return }
        mac.send(mac.magnify(by: 0, .ended, at: held.point))
        lift(held, in: mac)
    }

    /// Where a held pinch's fingers rest in the Mac window, whether its pointer entered the
    /// window for it, and the gauge that reads its scale, until it is released or the screen
    /// closes.
    struct HeldPoint {
        let point: CGPoint
        let entered: Bool
        let gauge: PinchGauge
    }

    static var heldPinch: HeldPoint?

    /// Takes the gauge off, moves the pointer out if the pinch brought it in, and moves the
    /// window back off every display, unless a hover holds it there.
    private static func lift(_ held: HeldPoint, in mac: MacWindow) {
        held.gauge.remove()
        if held.entered, let area = mac.trackingArea {
            mac.send(mac.crossing(.exited, area, at: held.point))
        }
        finishPinch(in: mac)
    }

    private static func finishPinch(in mac: MacWindow) {
        if !isHovering { mac.moveOffScreen() }
    }

    /// Sends changed magnify events that move the pinch to `scale`, in even steps of the
    /// scale the gauge reads, then a few more to correct what is left, until it reads within
    /// a ten-thousandth or so. UIKit makes a pinch in's scale from the events' magnification
    /// by a curve it does not document, so each step aims by the slope the last one showed.
    /// Where the gauge hears no pinch yet, the scale is taken as the sum, as a Mac app's.
    private static func steer(
        to scale: Double, at point: CGPoint, in mac: MacWindow, by gauge: PinchGauge
    ) async -> Bool {
        let steps = PinchDirection.stepCount
        var magnification = 0.0
        var reached = 1.0
        var slope = 1.0
        for step in 1...(steps + corrections) {
            let target = 1 + (scale - 1) * Double(min(step, steps)) / Double(steps)
            if step > steps, abs(reached - scale) <= tolerance { break }
            let amount = (target - reached) / slope
            guard await magnify([(.changed, amount)], at: point, in: mac) else { return false }
            magnification += amount
            let read = gauge.scale ?? 1 + magnification
            let shown = (read - reached) / amount
            if shown.isFinite, shown > 0 { slope = shown }
            reached = read
        }
        return true
    }

    /// How many changed events may follow the even steps to correct the scale, and how near
    /// they bring it.
    private static let corrections = 6
    private static let tolerance = 0.0001

    /// Sends the magnify events, a run loop turn apart; whether each could be made.
    private static func magnify(
        _ steps: [(GesturePhase, Double)], at point: CGPoint, in mac: MacWindow
    ) async -> Bool {
        for (phase, amount) in steps {
            guard let event = mac.magnify(by: amount, phase, at: point) else { return false }
            mac.send(event)
            await Task.yield()
        }
        return true
    }
}

/// A pinch recognizer on the test's window for the length of a pinch. It hears the magnify
/// events the app's own gestures hear and reads the scale UIKit makes of them, so the pinch
/// can steer to the scale the test asks for. It recognizes alongside every other gesture
/// and holds back no touch, so the app's gestures run as they would without it.
@MainActor
final class PinchGauge: NSObject, UIGestureRecognizerDelegate {
    private let recognizer = UIPinchGestureRecognizer()

    init(on window: UIWindow) {
        super.init()
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = self
        window.addGestureRecognizer(recognizer)
    }

    /// The scale the pinch has reached, once UIKit hears it as begun.
    var scale: Double? {
        switch recognizer.state {
        case .began, .changed: Double(recognizer.scale)
        default: nil
        }
    }

    func remove() {
        recognizer.view?.removeGestureRecognizer(recognizer)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

#endif
