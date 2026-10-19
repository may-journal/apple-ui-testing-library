#if canImport(UIKit)
import ObjectiveC
import UIKit

/// The Mac window a scene draws in, when the iOS app runs on a Mac: AppKit is in the
/// process then, and its window takes mouse events made in process, as the mouse sends
/// them. UIKit names no public bridge to it, so it is reached by name (ADR 0011).
@MainActor
struct MacWindow {
    private let window: NSObject
    private let content: NSObject

    /// The window the app's scene draws in, if the app runs on a Mac.
    static var current: MacWindow? {
        guard ProcessInfo.processInfo.isiOSAppOnMac,
            let application = NSClassFromString("NSApplication") as? NSObject.Type,
            let shared = application.value(forKey: "sharedApplication") as? NSObject,
            let windows = shared.value(forKey: "windows") as? [NSObject]
        else { return nil }
        for window in windows {
            guard let content = window.value(forKey: "contentView") as? NSObject,
                String(describing: type(of: content)).contains("Scene")
            else { continue }
            return MacWindow(window: window, content: content)
        }
        return nil
    }

    /// The displays' frames, in AppKit's screen coordinates.
    private static var displays: [CGRect] {
        guard let screen = NSClassFromString("NSScreen") as? NSObject.Type,
            let screens = screen.value(forKey: "screens") as? [NSObject]
        else { return [] }
        return screens.compactMap { $0.value(forKey: "frame") as? CGRect }
    }

    private var frame: CGRect { window.value(forKey: "frame") as? CGRect ?? .zero }

    var isOffScreen: Bool { !Self.displays.contains { $0.intersects(frame) } }

    /// Moves the window past the right and top edges of every display.
    func moveOffScreen() {
        hide()
        guard !isOffScreen else { return }
        let all = Self.displays.reduce(CGRect.null) { $0.union($1) }
        move(
            to: all.isNull
                ? CGPoint(x: 100_000, y: 100_000)
                : CGPoint(x: all.maxX + 10_000, y: all.maxY + 10_000))
    }

    /// Moves the window onto the first display, see-through and passing every click of the
    /// person's own through, for a hover: the scene hears the pointer only where a display
    /// shows it. Nothing shows, and the next screen moves it off again (ADR 0011).
    func moveOnScreenUnseen() {
        guard isOffScreen, let display = Self.displays.first else { return }
        hide()
        move(to: display.origin)
    }

    /// Makes the window see-through and lets the person's clicks pass through it.
    private func hide() {
        window.setValue(0.0, forKey: "alphaValue")
        window.setValue(true, forKey: "ignoresMouseEvents")
    }

    private func move(to origin: CGPoint) {
        var moved = frame
        moved.origin = origin
        // The scene's window pulls itself back onto a display unless told not to.
        let ignore = NSSelectorFromString("_setIgnoreConstrainFrameToScreen:")
        if window.responds(to: ignore),
            let method = class_getMethodImplementation(type(of: window), ignore)
        {
            typealias SetIgnore = @convention(c) (NSObject, Selector, Bool) -> Void
            unsafeBitCast(method, to: SetIgnore.self)(window, ignore, true)
        }
        let selector = NSSelectorFromString("setFrame:display:")
        guard let method = class_getMethodImplementation(type(of: window), selector) else { return }
        typealias SetFrame = @convention(c) (NSObject, Selector, CGRect, Bool) -> Void
        unsafeBitCast(method, to: SetFrame.self)(window, selector, moved, false)
    }

    /// The tracking area the scene's input view hears the pointer through.
    var trackingArea: NSObject? {
        func views(_ view: NSObject) -> [NSObject] {
            [view] + ((view.value(forKey: "subviews") as? [NSObject]) ?? []).flatMap(views)
        }
        return views(content).lazy.compactMap {
            ($0.value(forKey: "trackingAreas") as? [NSObject])?.first
        }.first { area in
            // The input view's area follows the pointer; others draw tool tips.
            (area.value(forKey: "options") as? UInt).map { $0 & 0x2 != 0 } ?? false
        }
    }

    /// The middle of `frame`, in a scene window's points, as a point in the Mac window,
    /// which draws the scene scaled and counts up from the bottom.
    func point(for frame: CGRect, in scene: UIWindow) -> CGPoint {
        let bounds = (content.value(forKey: "frame") as? CGRect) ?? .zero
        let width = scene.windowScene?.coordinateSpace.bounds.width ?? bounds.width
        let scale = width > 0 ? bounds.width / width : 1
        // The test's window sits at the scene's origin, so its points are the scene's.
        let middle = CGPoint(x: frame.midX, y: frame.midY)
        return CGPoint(x: middle.x * scale, y: bounds.height - middle.y * scale)
    }

    enum Mouse: UInt {
        case leftDown = 1
        case leftUp = 2
        case moved = 5
        case dragged = 6
    }

    enum Crossing: UInt {
        case entered = 8
        case exited = 9
    }

    func mouse(_ type: Mouse, at point: CGPoint, clicks: Int) -> NSObject? {
        let selector = NSSelectorFromString(
            "mouseEventWithType:location:modifierFlags:timestamp:windowNumber:context:"
                + "eventNumber:clickCount:pressure:")
        typealias Make =
            @convention(c) (
                AnyClass, Selector, UInt, CGPoint, UInt, Double, Int, AnyObject?, Int, Int, Float
            ) -> Unmanaged<NSObject>?
        guard let event = NSClassFromString("NSEvent"),
            let method = class_getClassMethod(event, selector)
        else { return nil }
        return unsafeBitCast(method_getImplementation(method), to: Make.self)(
            event, selector, type.rawValue, point, 0, ProcessInfo.processInfo.systemUptime,
            number, nil, 0, clicks, type == .leftDown || type == .dragged ? 1 : 0
        )?.takeUnretainedValue()
    }

    func crossing(_ type: Crossing, _ area: NSObject, at point: CGPoint) -> NSObject? {
        let selector = NSSelectorFromString(
            "enterExitEventWithType:location:modifierFlags:timestamp:windowNumber:context:"
                + "eventNumber:trackingNumber:userData:")
        typealias Make =
            @convention(c) (
                AnyClass, Selector, UInt, CGPoint, UInt, Double, Int, AnyObject?, Int, Int,
                UnsafeMutableRawPointer?
            ) -> Unmanaged<NSObject>?
        guard let event = NSClassFromString("NSEvent"),
            let method = class_getClassMethod(event, selector)
        else { return nil }
        return unsafeBitCast(method_getImplementation(method), to: Make.self)(
            event, selector, type.rawValue, point, 0, ProcessInfo.processInfo.systemUptime,
            number, nil, 0, Int(bitPattern: Unmanaged.passUnretained(area).toOpaque()), nil
        )?.takeUnretainedValue()
    }

    /// A trackpad's magnify event at `point` in the window, as a pinch sends.
    func magnify(by amount: Double, _ phase: GesturePhase, at point: CGPoint) -> NSObject? {
        Trackpad.magnify(by: amount, phase, at: point, inWindow: number, height: frame.height)
    }

    /// Whether the window server has the window where AppKit last moved it, as Quartz's
    /// window list tells. A move reaches the window server a moment after AppKit makes it.
    var isPlaced: Bool {
        typealias CopyInfo = @convention(c) (UInt32, UInt32) -> Unmanaged<CFArray>?
        guard
            let symbol = dlsym(
                UnsafeMutableRawPointer(bitPattern: -2), "CGWindowListCopyWindowInfo")
        else { return false }
        let includingWindow: UInt32 = 1 << 3
        guard
            let info = unsafeBitCast(symbol, to: CopyInfo.self)(includingWindow, UInt32(number))?
                .takeRetainedValue() as? [[String: Any]],
            let bounds = info.first?["kCGWindowBounds"] as? [String: Double],
            let height = Self.displays.first?.height
        else { return false }
        // Quartz counts down from the top of the first display; AppKit up from its bottom.
        return bounds["X"] == frame.minX && bounds["Y"] == height - frame.maxY
    }

    private var number: Int { window.value(forKey: "windowNumber") as? Int ?? 0 }

    /// Hands the event straight to the window, as AppKit does with one from the mouse.
    func send(_ event: NSObject?) {
        guard let event else { return }
        window.perform(NSSelectorFromString("sendEvent:"), with: event)
    }
}
#endif
