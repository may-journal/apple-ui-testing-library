#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Presses keys in the AppKit field being edited, as the keyboard sends them: each key runs
/// its editing command, which the field's delegate hears first. Also clears a field and
/// finds the system share picker over the window.
extension Backend {
    /// Presses `key` in the field being edited; whether one was. Enter runs insert newline,
    /// which ends a one-line field's editing and sends its action. End moves to the end.
    static func press(_ key: Key, in window: HostWindow) -> Bool {
        guard let field = editing(in: window) else { return false }
        switch key {
        case .enter: field.doCommand(by: #selector(NSResponder.insertNewline(_:)))
        case .end: field.doCommand(by: #selector(NSResponder.moveToEndOfDocument(_:)))
        }
        return true
    }

    /// Makes the field under the element the one being edited, as a click into it does;
    /// whether the element takes text.
    static func edit(_ node: Node, in window: HostWindow) -> Bool {
        guard node.element.isEnabled else { return false }
        let front = frontWindow(of: window.window)
        var view = node.object as? NSView ?? hitView(at: node.element.frame, in: front)
        while let current = view, !(current is NSTextField || current is NSTextView) {
            view = current.superview
        }
        guard let field = view else { return false }
        if let editor = editing(in: window), editor.delegate === field { return true }
        return front.makeFirstResponder(field)
    }

    /// The deepest view drawn at the middle of `frame`, in window coordinates.
    private static func hitView(at frame: CGRect, in window: NSWindow) -> NSView? {
        guard let root = window.contentView, let parent = root.superview else { return nil }
        let middle = CGPoint(x: frame.midX, y: frame.midY)
        return root.hitTest(parent.convert(middle, from: nil))
    }

    /// Deletes every character in the field being edited, as holding Delete at its end does;
    /// whether one was.
    static func clearField(in window: HostWindow) -> Bool {
        guard let field = editing(in: window) else { return false }
        field.doCommand(by: #selector(NSResponder.moveToEndOfDocument(_:)))
        var left = field.string.count
        while !field.string.isEmpty, left > 0 {
            field.doCommand(by: #selector(NSResponder.deleteBackward(_:)))
            left -= 1
        }
        return true
    }

    /// The text view editing in the front window: a one-line field's shared field editor, or
    /// a text view of its own.
    private static func editing(in window: HostWindow) -> NSTextView? {
        frontWindow(of: window.window).firstResponder as? NSTextView
    }

    /// Whether the system share picker is up over the window. It opens in a popover window
    /// of its own, whose controller shows the share sheet from another process; AppKit names
    /// no public type for it, so the controller's class name tells it (ADR 0010).
    static func isSharing(over window: HostWindow) -> Bool {
        NSApp.windows.contains { shown in
            guard shown.isVisible, let controller = shown.contentViewController else {
                return false
            }
            return String(describing: Swift.type(of: controller)).contains("ShareSheet")
        }
    }
}
#endif
