#if canImport(UIKit)
import UIKit

/// Presses keys in the UIKit field being edited, as the keyboard sends them, clears a field,
/// and finds the system share sheet presented over the window.
extension Backend {
    /// Presses `key` in the field being edited; whether one was. Enter submits a one-line
    /// field, as the field hears the key: its delegate first, then its end-on-exit action.
    /// A field of many lines takes a new line instead. End moves the cursor to the end.
    static func press(_ key: Key, in window: HostWindow) -> Bool {
        guard let field = editing(in: window.window) else { return false }
        switch key {
        case .enter: enter(field)
        case .end: moveToEnd(field)
        }
        return true
    }

    private static func enter(_ field: UIKeyInput) {
        guard let line = field as? UITextField else {
            field.insertText("\n")
            return
        }
        if line.delegate?.textFieldShouldReturn?(line) != false {
            line.sendActions(for: .editingDidEndOnExit)
        }
    }

    /// Asks the element's field to be the one being edited, as a tap into it does; whether
    /// it is now. SwiftUI may move focus a turn later, so a caller asks again until it is.
    static func edit(_ node: Node, in window: HostWindow) -> Bool {
        guard node.element.isEnabled, let field = node.object as? UIView, field is UITextInput
        else { return false }
        if !field.isFirstResponder { _ = field.becomeFirstResponder() }
        return field.isFirstResponder
    }

    /// Deletes every character in the field being edited, as holding Delete at its end does;
    /// whether one was.
    static func clearField(in window: HostWindow) -> Bool {
        guard let field = editing(in: window.window) else { return false }
        moveToEnd(field)
        var left = (field as? UITextInput).map { length(of: $0) } ?? Int.max
        while field.hasText, left > 0 {
            field.deleteBackward()
            left -= 1
        }
        return true
    }

    private static func moveToEnd(_ field: UIKeyInput) {
        guard let input = field as? UITextInput else { return }
        input.selectedTextRange = input.textRange(
            from: input.endOfDocument, to: input.endOfDocument)
    }

    private static func length(of input: UITextInput) -> Int {
        input.offset(from: input.beginningOfDocument, to: input.endOfDocument)
    }

    /// Whether the system share sheet is up over the window: an activity view controller
    /// presented there, alone or inside the sheet that holds it. It draws outside the app,
    /// so only its controller is seen, never its contents.
    static func isSharing(over window: HostWindow) -> Bool {
        let windows = window.window.windowScene?.windows ?? [window.window]
        return windows.contains { window in
            var shown = window.rootViewController?.presentedViewController
            while let controller = shown {
                if holdsActivity(controller) { return true }
                shown = controller.presentedViewController
            }
            return false
        }
    }

    private static func holdsActivity(_ controller: UIViewController) -> Bool {
        controller is UIActivityViewController || controller.children.contains(where: holdsActivity)
    }
}
#endif
