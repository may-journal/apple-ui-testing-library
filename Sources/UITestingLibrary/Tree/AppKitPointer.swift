#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Drives AppKit with the pointer events a mouse or trackpad sends, built in process and
/// handed straight to the test's own window, which sits off every display: clicks, hovers
/// and drags (ADR 0011). VoiceOver's own entry points come first where AppKit has them:
/// increment and decrement adjust a control, and a view's context menu opens as a press
/// and hold does.
extension Backend {
    /// A place for the window off every display: past the right and top edges of them all.
    static var offScreenOrigin: CGPoint {
        let all = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
        guard !all.isNull else { return CGPoint(x: 100_000, y: 100_000) }
        return CGPoint(x: all.maxX + 10_000, y: all.maxY + 10_000)
    }

    /// Whether no display shows any part of the window.
    static func isOffScreen(_ window: HostWindow) -> Bool {
        let frame = window.window.frame
        return !NSScreen.screens.contains { $0.frame.intersects(frame) }
    }

    /// Clicks the middle of the element twice, as a double click sends: the second press
    /// counts two clicks. Whether the element is drawn.
    static func doubleTap(_ node: Node, in window: HostWindow) async -> Bool {
        let front = frontWindow(of: window.window)
        guard let point = middle(of: node) else { return false }
        for clicks in 1...2 {
            send(mouse(.leftMouseDown, at: point, clicks: clicks, in: front), to: front)
            send(mouse(.leftMouseUp, at: point, clicks: clicks, in: front), to: front)
            // A person's clicks come one run loop turn apart, at least.
            await Task.yield()
        }
        return true
    }

    /// Opens the context menu of the view under the element, as a press and hold or a
    /// secondary click does, without drawing it: the view answers its menu for that click,
    /// and its items become what a read holds. Whether the view offers one.
    static func longPress(_ node: Node, in window: HostWindow) -> Bool {
        let front = frontWindow(of: window.window)
        guard let point = middle(of: node),
            let click = mouse(.rightMouseDown, at: point, clicks: 1, in: front)
        else { return false }
        var view = hitView(at: node.element.frame, in: front)
        while let current = view {
            if let menu = current.menu(for: click), !menu.items.isEmpty {
                holdMenu(menu)
                return true
            }
            view = current.superview
        }
        return false
    }

    /// Moves the pointer onto the element: into the tracking areas drawn there, then over
    /// its middle. Whether the element is drawn.
    static func hover(_ node: Node, in window: HostWindow) -> Bool {
        let front = frontWindow(of: window.window)
        guard let point = middle(of: node) else { return false }
        for area in trackingAreas(at: point, in: front) where !hovered.contains(area) {
            send(crossing(.mouseEntered, area, at: point, in: front), to: front)
            hovered.append(area)
        }
        send(mouse(.mouseMoved, at: point, clicks: 0, in: front), to: front)
        return true
    }

    /// Moves the pointer off the element and out of the tracking areas it entered. Whether
    /// it was over any.
    static func unhover(_ node: Node, in window: HostWindow) -> Bool {
        let front = frontWindow(of: window.window)
        guard let point = middle(of: node), !hovered.isEmpty else { return false }
        for area in hovered.reversed() {
            send(crossing(.mouseExited, area, at: point, in: front), to: front)
        }
        hovered = []
        return true
    }

    /// The tracking areas the pointer is inside after a hover, until it leaves them.
    private static var hovered: [NSTrackingArea] = []

    /// Forgets the pointer and puts back the clipboard as a screen closes.
    static func endPointer() {
        hovered = []
        forgetDrag()
        Clipboard.restore()
    }

    /// The tracking areas of the view drawn at `point` and the views holding it, each
    /// containing the point.
    private static func trackingAreas(at point: CGPoint, in window: NSWindow) -> [NSTrackingArea] {
        guard let root = window.contentView, let parent = root.superview else { return [] }
        var areas: [NSTrackingArea] = []
        var view = root.hitTest(parent.convert(point, from: nil))
        while let current = view {
            let local = current.convert(point, from: nil)
            areas += current.trackingAreas.filter { area in
                let rect = area.options.contains(.inVisibleRect) ? current.visibleRect : area.rect
                return rect.contains(local)
            }
            view = current.superview
        }
        return areas.reversed()
    }

    /// Steps the element's value up or down, as VoiceOver's swipe up and down on a slider or
    /// stepper does; whether it offers that.
    static func adjust(_ direction: AdjustDirection, _ node: Node) -> Bool {
        let object = node.object
        switch direction {
        case .up:
            // SwiftUI's stepper answers false yet steps, so answering at all counts.
            return object.accessibilityPerformIncrement?() != nil || performs(.increment, object)
        case .down:
            return object.accessibilityPerformDecrement?() != nil || performs(.decrement, object)
        }
    }

    /// Runs the named action on an element that answers only AppKit's older protocol, as a
    /// stepper's cell does; whether it offers the action.
    private static func performs(_ action: NSAccessibility.Action, _ object: AnyObject) -> Bool {
        guard let element = object as? NSObject,
            element.accessibilityActionNames().contains(action)
        else { return false }
        element.accessibilityPerformAction(action)
        return true
    }

    /// Swipes a row to show its actions. AppKit shows a row's swipe actions only for a
    /// trackpad's touches, which no event made in process carries (ADR 0011).
    static func swipe(_ direction: SwipeDirection, _ node: Node, in window: HostWindow) -> Bool {
        false
    }

    /// The element's middle in window coordinates, if it is drawn.
    static func middle(of node: Node) -> CGPoint? {
        let frame = node.element.frame
        return frame.isEmpty ? nil : CGPoint(x: frame.midX, y: frame.midY)
    }

    static func mouse(
        _ type: NSEvent.EventType, at point: CGPoint, clicks: Int, in window: NSWindow,
        time: TimeInterval? = nil
    ) -> NSEvent? {
        NSEvent.mouseEvent(
            with: type, location: point, modifierFlags: [],
            timestamp: time ?? ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber,
            context: nil, eventNumber: 0, clickCount: clicks,
            pressure: type == .leftMouseDown || type == .leftMouseDragged ? 1 : 0)
    }

    /// The event a pointer sends crossing into or out of `area`, which AppKit hands to the
    /// area's owner.
    private static func crossing(
        _ type: NSEvent.EventType, _ area: NSTrackingArea, at point: CGPoint, in window: NSWindow
    ) -> NSEvent? {
        NSEvent.enterExitEvent(
            with: type, location: point, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: window.windowNumber,
            context: nil, eventNumber: 0,
            trackingNumber: Int(bitPattern: Unmanaged.passUnretained(area).toOpaque()),
            userData: nil)
    }

    /// Hands the event straight to the window, as AppKit does with one from the mouse.
    static func send(_ event: NSEvent?, to window: NSWindow) {
        if let event { window.sendEvent(event) }
    }
}

#endif
