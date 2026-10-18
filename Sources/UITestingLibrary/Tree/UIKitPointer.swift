#if canImport(UIKit)
import ObjectiveC
import UIKit

/// Drives UIKit beyond a tap. VoiceOver's own entry points come first: increment and
/// decrement adjust a control, and a view's context menu interaction and its drag and drop
/// interactions answer as they do for a person, through their delegates. A double tap and
/// a hover need the pointer: a Mac running the iOS app sends its mouse events in process to
/// the scene's window, which sits off every display (ADR 0011).
extension Backend {
    /// Moves the scene's Mac window off every display, so nothing a test draws shows on
    /// screen. An iPhone or iPad has no other place to draw, so there it stays.
    static func moveOffScreen(_ scene: UIWindowScene) {
        MacWindow.current?.moveOffScreen()
    }

    /// Whether no display shows any part of the window: on a Mac, whether its scene's
    /// window is off every display.
    static func isOffScreen(_ window: HostWindow) -> Bool {
        MacWindow.current?.isOffScreen ?? false
    }

    /// Clicks the middle of the element twice, as a double click on a Mac sends, which the
    /// iOS app hears as a double tap. Whether the app runs on a Mac, where events can be made
    /// in process.
    static func doubleTap(_ node: Node, in window: HostWindow) async -> Bool {
        guard let mac = MacWindow.current else { return false }
        let point = mac.point(for: node.element.frame, in: window.window)
        // A person's presses and releases come a run loop turn apart, at least; sent together,
        // the app hears two taps.
        for clicks in 1...2 {
            mac.send(mac.mouse(.leftDown, at: point, clicks: clicks))
            await Task.yield()
            mac.send(mac.mouse(.leftUp, at: point, clicks: clicks))
            await Task.yield()
        }
        return true
    }

    /// Opens the context menu of the view under the element, as a press and hold does,
    /// without drawing it: the view's context menu interaction gives the menu it would show
    /// there, and its items become what a read holds. Whether the view offers one.
    static func longPress(_ node: Node, in window: HostWindow) -> Bool {
        guard let object = node.object as? NSObject else { return false }
        let point = window.window.convert(object.accessibilityActivationPoint, from: nil)
        for view in views(at: point, in: window.window) {
            for case let interaction as UIContextMenuInteraction in view.interactions {
                let location = view.convert(point, from: window.window)
                guard
                    let configuration = interaction.delegate?.contextMenuInteraction(
                        interaction, configurationForMenuAtLocation: location),
                    let menu = menu(of: configuration), !menu.children.isEmpty
                else { continue }
                holdMenu(menu)
                return true
            }
        }
        return false
    }

    /// The menu a configuration builds. UIKit keeps its builder private; the configuration
    /// answers it by name, and a rename makes the hold fail, never pass (ADR 0011).
    private static func menu(of configuration: UIContextMenuConfiguration) -> UIMenu? {
        let key = "actionProvider"
        guard configuration.responds(to: NSSelectorFromString(key)),
            let provider = configuration.value(forKey: key) as AnyObject?
        else { return nil }
        typealias Provider = @convention(block) ([UIMenuElement]) -> UIMenu?
        return unsafeBitCast(provider, to: Provider.self)([])
    }

    /// Moves the pointer onto the element: into the scene's tracking area, then over its
    /// middle, as a Mac's mouse does. Whether the app runs on a Mac.
    static func hover(_ node: Node, in window: HostWindow) -> Bool {
        guard let mac = MacWindow.current, let area = mac.trackingArea else { return false }
        mac.moveOnScreenUnseen()
        let point = mac.point(for: node.element.frame, in: window.window)
        if !isHovering {
            mac.send(mac.crossing(.entered, area, at: point))
            isHovering = true
        }
        mac.send(mac.mouse(.moved, at: point, clicks: 0))
        return true
    }

    /// Moves the pointer off the element and out of the scene's tracking area. Whether it
    /// was over the window.
    static func unhover(_ node: Node, in window: HostWindow) -> Bool {
        guard let mac = MacWindow.current, let area = mac.trackingArea, isHovering else {
            return false
        }
        mac.send(
            mac.crossing(.exited, area, at: mac.point(for: node.element.frame, in: window.window)))
        isHovering = false
        return true
    }

    private static var isHovering = false

    /// Forgets the pointer and puts back the clipboard as a screen closes.
    static func endPointer() {
        isHovering = false
        Clipboard.restore()
    }

    /// Steps the element's value up or down, as VoiceOver's swipe up and down does; whether
    /// it is a slider or stepper. A stepper on a Mac running the iOS app answers no
    /// increment, so it then steps as its own buttons do.
    static func adjust(_ direction: AdjustDirection, _ node: Node) -> Bool {
        guard let object = node.object as? NSObject,
            object is UIStepper || object.accessibilityTraits.contains(.adjustable)
        else { return false }
        let before = (object as? UIStepper)?.value
        if direction == .up {
            object.accessibilityIncrement()
        } else {
            object.accessibilityDecrement()
        }
        if let stepper = object as? UIStepper, stepper.value == before {
            step(stepper, direction)
        }
        return true
    }

    /// Steps a stepper by one step, as its buttons do, and sends its value-changed action.
    private static func step(_ stepper: UIStepper, _ direction: AdjustDirection) {
        let step = direction == .up ? stepper.stepValue : -stepper.stepValue
        stepper.value = min(stepper.maximumValue, max(stepper.minimumValue, stepper.value + step))
        stepper.sendActions(for: .valueChanged)
    }

    /// Swipes the row under the element to show its actions, as a person's swipe does: the
    /// list's swipe controller opens the row. UIKit keeps that controller private; the list
    /// answers it by name, and a rename makes the swipe fail, never pass (ADR 0011).
    static func swipe(_ direction: SwipeDirection, _ node: Node, in window: HostWindow) -> Bool {
        guard let object = node.object as? NSObject else { return false }
        let point = window.window.convert(object.accessibilityActivationPoint, from: nil)
        guard
            let list = views(at: point, in: window.window).lazy.compactMap({
                $0 as? UICollectionView
            }).first,
            let path = list.indexPathForItem(at: list.convert(point, from: window.window)),
            let controller = swipeController(of: list)
        else { return false }
        let selector = NSSelectorFromString(
            "swipeItemAtIndexPath:configuration:direction:animated:completion:")
        guard controller.responds(to: selector),
            let method = class_getMethodImplementation(Swift.type(of: controller), selector)
        else { return false }
        typealias Swipe =
            @convention(c) (
                NSObject, Selector, NSIndexPath, AnyObject?, Int, Bool, AnyObject?
            ) -> Void
        // The controller's directions: 1 shows the trailing actions a left swipe reveals.
        unsafeBitCast(method, to: Swipe.self)(
            controller, selector, path as NSIndexPath, nil, direction == .left ? 1 : 0, false, nil)
        return true
    }

    /// The list's swipe controller, which its swipe recognizer's handler names.
    private static func swipeController(of list: UICollectionView) -> NSObject? {
        let handler =
            list.gestureRecognizers?.first {
                String(describing: Swift.type(of: $0)).contains("SwipeAction")
            }?.delegate as? NSObject
        let key = "swipeController"
        guard let handler, handler.responds(to: NSSelectorFromString(key)) else { return nil }
        return handler.value(forKey: key) as? NSObject
    }

    /// The view drawn at `point`, then each view holding it, up to the window.
    static func views(at point: CGPoint, in window: UIWindow) -> [UIView] {
        var found: [UIView] = []
        var view = window.hitTest(point, with: nil)
        while let current = view {
            found.append(current)
            view = current.superview
        }
        return found
    }
}

#endif
