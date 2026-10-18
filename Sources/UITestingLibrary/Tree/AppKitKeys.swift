#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Presses keys in the AppKit field being edited, as the keyboard sends them: a key goes to
/// the window's key equivalents first, so a shortcut answers it, then to the field, whose
/// delegate hears its editing command first. Also clears a field and finds the system share
/// picker over the window.
extension Backend {
    /// Presses `key` with `modifiers` in the field being edited; whether one was. Enter runs
    /// insert newline, which ends a one-line field's editing and sends its action; Home and
    /// End move to the start and end, as user-event's keys do, where a Mac's would scroll.
    static func press(
        _ key: Key, with modifiers: Set<Modifier>, nodes: [Node], in window: HostWindow
    ) -> Bool {
        let front = frontWindow(of: window.window)
        guard let field = editing(in: window), let event = keyEvent(key, modifiers, in: front)
        else { return false }
        if front.performKeyEquivalent(with: event) { return true }
        if let command = commands[key]?[modifiers] {
            field.doCommand(by: command)
        } else {
            field.keyDown(with: event)
        }
        return true
    }

    /// The editing command a key runs, by the modifiers held, where it runs one directly:
    /// Enter inserts a newline, and Home and End move to the ends, with Shift selecting.
    private static let commands: [Key: [Set<Modifier>: Selector]] = [
        .enter: [[]: #selector(NSResponder.insertNewline(_:))],
        .end: [
            []: #selector(NSResponder.moveToEndOfDocument(_:)),
            [.shift]: #selector(NSResponder.moveToEndOfDocumentAndModifySelection(_:)),
        ],
        .home: [
            []: #selector(NSResponder.moveToBeginningOfDocument(_:)),
            [.shift]: #selector(NSResponder.moveToBeginningOfDocumentAndModifySelection(_:)),
        ],
    ]

    /// The key-down event the keyboard sends for `key`, addressed to `window`.
    private static func keyEvent(_ key: Key, _ modifiers: Set<Modifier>, in window: NSWindow)
        -> NSEvent?
    {
        guard let (code, plain) = keys[key] else { return nil }
        var flags = NSEvent.ModifierFlags(modifiers.compactMap { flags[$0] })
        if [.left, .right, .up, .down, .home, .end].contains(key) {
            flags.formUnion([.function, .numericPad])
        }
        // Shift-Tab types the back-tab character, as the keyboard does.
        let typed = key == .tab && modifiers.contains(.shift) ? "\u{19}" : plain
        return NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: flags,
            timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: window.windowNumber,
            context: nil, characters: typed, charactersIgnoringModifiers: plain,
            isARepeat: false, keyCode: code)
    }

    private static let flags: [Modifier: NSEvent.ModifierFlags] = [
        .command: .command, .shift: .shift, .option: .option, .control: .control,
    ]

    /// Each key's virtual key code and the characters it types.
    private static let keys: [Key: (UInt16, String)] = [
        .enter: (36, "\r"), .tab: (48, "\t"), .delete: (51, "\u{7f}"), .escape: (53, "\u{1b}"),
        .home: (115, string(NSHomeFunctionKey)), .end: (119, string(NSEndFunctionKey)),
        .left: (123, string(NSLeftArrowFunctionKey)),
        .right: (124, string(NSRightArrowFunctionKey)),
        .down: (125, string(NSDownArrowFunctionKey)), .up: (126, string(NSUpArrowFunctionKey)),
    ]

    private static func string(_ functionKey: Int) -> String {
        UnicodeScalar(UInt16(functionKey)).map { String(Character($0)) } ?? ""
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
    static func hitView(at frame: CGRect, in window: NSWindow) -> NSView? {
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
    static func editing(in window: HostWindow) -> NSTextView? {
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
