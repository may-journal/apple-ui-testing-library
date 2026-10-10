#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Drives AppKit elements through what VoiceOver offers: press, custom actions, the
/// keyboard, scrolling, and cancel to go back.
extension Backend {
    /// Presses the element; whether it answered.
    static func activate(_ node: Node, in window: HostWindow) -> Bool {
        node.object.accessibilityPerformPress?() ?? false
    }

    /// Runs the custom action named `name` on the element; whether it was offered.
    static func perform(_ name: String, on node: Node) -> Bool {
        let actions = node.object.accessibilityCustomActions?() ?? []
        guard let action = actions.first(where: { $0.name == name }) else { return false }
        if let handler = action.handler { return handler() }
        guard let target = action.target, let selector = action.selector else { return false }
        _ = target.perform(selector)
        return true
    }

    /// Types into the field being edited; whether one was.
    static func type(_ text: String, in window: HostWindow) -> Bool {
        guard let field = window.window.firstResponder as? NSTextInputClient else { return false }
        field.insertText(text, replacementRange: NSRange(location: NSNotFound, length: 0))
        return true
    }

    /// Scrolls the front scroll view by most of its height; whether one was there.
    static func scroll(_ direction: ScrollDirection, nodes: [Node], in window: HostWindow) -> Bool {
        guard let root = window.window.contentView, let page = scrollView(in: root) else {
            return false
        }
        let height = page.contentView.bounds.height
        let step = height * 0.8
        var origin = page.contentView.bounds.origin
        let bottom = max(0, (page.documentView?.frame.height ?? 0) - height)
        origin.y = direction == .down ? min(bottom, origin.y + step) : max(0, origin.y - step)
        page.contentView.scroll(to: origin)
        page.reflectScrolledClipView(page.contentView)
        return true
    }

    private static func scrollView(in view: NSView) -> NSScrollView? {
        if let page = view as? NSScrollView { return page }
        return view.subviews.lazy.compactMap(scrollView(in:)).first
    }

    /// Cancels from the front element, or a view holding it; whether one answered.
    static func goBack(from nodes: [Node], in window: HostWindow) -> Bool {
        var next: AnyObject? = nodes.last(where: \.element.isOnScreen)?.object
        while let current = next {
            if current.accessibilityPerformCancel?() == true { return true }
            next = (current as? NSView)?.superview ?? current.accessibilityParent?() as AnyObject?
        }
        return false
    }
}
#endif
