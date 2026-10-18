#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Presses keys in the AppKit field being edited, as the keyboard sends them: each key runs
/// its editing command, which the field's delegate hears first. Also finds the system share
/// picker over the window.
extension Backend {
    /// Presses `key` in the field being edited; whether one was. Return runs insert newline,
    /// which ends a one-line field's editing and sends its action.
    static func press(_ key: Key, in window: HostWindow) -> Bool {
        switch key {
        case .return: command(#selector(NSResponder.insertNewline(_:)), in: window)
        }
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

    /// Moves the cursor to the end of the field being edited, as the End key does; whether
    /// one was.
    static func moveToEnd(in window: HostWindow) -> Bool {
        command(#selector(NSResponder.moveToEndOfDocument(_:)), in: window)
    }

    private static func command(_ selector: Selector, in window: HostWindow) -> Bool {
        guard let field = editing(in: window) else { return false }
        field.doCommand(by: selector)
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
