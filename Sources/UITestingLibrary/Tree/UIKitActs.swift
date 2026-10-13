#if canImport(UIKit)
import UIKit

/// Drives UIKit elements through what VoiceOver offers: activation, custom actions, the
/// keyboard, a three-finger scroll, and the two-finger scrub that goes back.
extension Backend {
    /// Opens the menu of the control under the element, activates the element, or presses
    /// the control under it when it answers no activation of its own, such as a navigation
    /// bar's Back; whether anything happened.
    static func activate(_ node: Node, in window: HostWindow) -> Bool {
        guard node.element.isEnabled else { return false }
        guard let object = node.object as? NSObject else { return false }
        if object is UIMenuElement { return choosesMenuItem(object) }
        if opensMenu(under: object, in: window.window) { return true }
        return object.accessibilityActivate()
            || pressesAlertButton(object)
            || pressesControl(under: object, in: window.window)
    }

    /// Presses the alert button the element shows, as a click on the Mac's native alert
    /// does. A Mac running the iOS app draws the alert itself, so UIKit's hidden copy answers
    /// no activation; the alert runs the button's handler as it closes. A disabled button
    /// presses nothing, as for a person.
    private static func pressesAlertButton(_ object: NSObject) -> Bool {
        var responder = object as? UIResponder
        while let current = responder, !(current is UIAlertController) { responder = current.next }
        let dismiss = NSSelectorFromString("_dismissWithAction:")
        guard let alert = responder as? UIAlertController, alert.responds(to: dismiss),
            let action = alert.actions.first(where: {
                $0.isEnabled && $0.title == object.accessibilityLabel
            })
        else { return false }
        alert.perform(dismiss, with: action)
        return true
    }

    private static func pressesControl(under object: NSObject, in window: UIWindow) -> Bool {
        let point = window.convert(object.accessibilityActivationPoint, from: nil)
        var view = window.hitTest(point, with: nil)
        while let current = view, !(current is UIControl) { view = current.superview }
        guard let control = view as? UIControl, control.isEnabled, !control.allTargets.isEmpty
        else { return false }
        control.sendActions(for: .touchUpInside)
        control.sendActions(for: .primaryActionTriggered)
        return true
    }

    /// Runs the custom action named `name` on the element; whether it was offered.
    static func perform(_ name: String, on node: Node) -> Bool {
        guard let object = node.object as? NSObject,
            let action = object.accessibilityCustomActions?.first(where: { $0.name == name })
        else { return false }
        if let handler = action.actionHandler {
            return handler(action)
        }
        guard let target = action.target as? NSObject else { return false }
        _ = target.perform(action.selector, with: action)
        return true
    }

    /// Types on the keyboard into the field being edited; whether one was.
    static func type(_ text: String, in window: HostWindow) -> Bool {
        guard let field = editing(in: window.window) else { return false }
        field.insertText(text)
        return true
    }

    private static func editing(in view: UIView) -> UIKeyInput? {
        if view.isFirstResponder, let input = view as? UIKeyInput { return input }
        return view.subviews.lazy.compactMap(editing(in:)).first
    }

    /// Scrolls the page in front by most of a screen; whether anything on screen scrolls.
    static func scroll(_ direction: ScrollDirection, nodes: [Node], in window: HostWindow)
        -> Bool
    {
        // The page in front comes last: a sheet's after the screen it covers.
        let shown = nodes.filter(\.element.isOnScreen).reversed()
        guard let page = shown.lazy.compactMap({ page(of: $0.object as? NSObject) }).first
        else { return false }
        let inset = page.adjustedContentInset
        let (top, step) = (-inset.top, page.bounds.height * 0.8)
        let bottom = max(top, page.contentSize.height - page.bounds.height + inset.bottom)
        var offset = page.contentOffset
        offset.y = direction == .down ? min(bottom, offset.y + step) : max(top, offset.y - step)
        page.setContentOffset(offset, animated: false)
        return true
    }

    /// The scroll view that scrolls the element up and down, if any.
    private static func page(of object: NSObject?) -> UIScrollView? {
        var container = object
        while let next = container, !(next is UIView) { container = next.accessibilityParent }
        var view = container as? UIView
        while let current = view {
            if let page = current as? UIScrollView, page.contentSize.height > page.bounds.height {
                return page
            }
            view = current.superview
        }
        return nil
    }

    /// Goes back as VoiceOver's scrub does: the front element answers it, or a view holding
    /// it; whether one did.
    static func goBack(from nodes: [Node], in window: HostWindow) -> Bool {
        if goBackOutOfMenu() { return true }
        guard let front = nodes.last(where: \.element.isOnScreen)?.object as? NSObject else {
            return false
        }
        var next: NSObject? = front
        while let current = next {
            if current.accessibilityPerformEscape() { return true }
            next = (current as? UIView)?.superview ?? current.accessibilityParent
        }
        return false
    }
}
#endif
