#if canImport(UIKit)
import UIKit

/// Presses keys as a hardware keyboard sends them: a key command up the responder chain,
/// from the field being edited or else the view on top, answers a key first, as a shortcut
/// does; otherwise the field edits as the key does. Also clears a field and finds the
/// system share sheet presented over the window.
extension Backend {
    /// Presses `key` with `modifiers`; whether a key command or the field being edited took
    /// it. A character types in the field. Enter submits a one-line field, as the field
    /// hears the key: its delegate first, then its end-on-exit action. A field of many lines
    /// takes a new line instead. Tab moves to the next field in reading order, or the one
    /// before with Shift.
    static func press(
        _ key: Key, with modifiers: Set<Modifier>, nodes: [Node], in window: HostWindow
    ) -> Bool {
        let field = editing(in: window.window)
        // With no field being edited, the key goes to the view on top, as a shortcut does.
        guard let first = field as? UIResponder ?? topController(of: window.window) else {
            return false
        }
        if runsKeyCommand(key, modifiers, from: first) { return true }
        guard let field else { return false }
        guard modifiers.isEmpty || modifiers == [.shift] else { return true }
        if case .character(let character) = key {
            field.insertText(String(character))
        } else {
            edits[key]?(field, !modifiers.isEmpty, nodes)
        }
        return true
    }

    /// The view controller drawn on top in the window: the last one presented over its root.
    private static func topController(of window: UIWindow) -> UIViewController? {
        var top = window.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }

    /// What each key does in the field, given whether Shift is held. Enter and Delete do
    /// nothing with Shift; the cursor keys then select as they move.
    private static let edits: [Key: @MainActor (UIKeyInput, Bool, [Node]) -> Void] = [
        .enter: { field, shift, _ in if !shift { enter(field) } },
        .delete: { field, shift, _ in if !shift { field.deleteBackward() } },
        .tab: { field, shift, nodes in moveFocus(from: field, backward: shift, nodes: nodes) },
        .end: { field, shift, _ in move(field, to: .end, extending: shift) },
        .down: { field, shift, _ in move(field, to: .end, extending: shift) },
        .home: { field, shift, _ in move(field, to: .start, extending: shift) },
        .up: { field, shift, _ in move(field, to: .start, extending: shift) },
        .left: { field, shift, _ in move(field, by: -1, extending: shift) },
        .right: { field, shift, _ in move(field, by: 1, extending: shift) },
    ]

    /// Runs the key command a responder from `first` up offers for the key, as the keyboard
    /// does before a field hears it; whether one did.
    private static func runsKeyCommand(
        _ key: Key, _ modifiers: Set<Modifier>, from first: UIResponder
    ) -> Bool {
        let flags = UIKeyModifierFlags(modifiers.compactMap { flags[$0] })
        let input = input(of: key)
        var responder: UIResponder? = first
        while let current = responder {
            let command = current.keyCommands?.first {
                $0.input == input && $0.modifierFlags == flags && $0.action != nil
            }
            // The responder that lists a command need not run it; the chain names who does.
            if let command, let action = command.action,
                let target = first.target(forAction: action, withSender: command) as? NSObject,
                target.responds(to: action)
            {
                return UIApplication.shared.sendAction(action, to: target, from: command, for: nil)
            }
            responder = current.next
        }
        return false
    }

    /// The input a key names a key command by: a character's own, lowercased as a key command
    /// lists it, or a named key's from the table below.
    private static func input(of key: Key) -> String? {
        guard case .character(let character) = key else { return inputs[key] }
        return character.lowercased()
    }

    /// The input each named key names a key command by.
    private static let inputs: [Key: String] = [
        .enter: "\r", .tab: "\t", .delete: "\u{8}", .escape: UIKeyCommand.inputEscape,
        .home: UIKeyCommand.inputHome, .end: UIKeyCommand.inputEnd,
        .left: UIKeyCommand.inputLeftArrow, .right: UIKeyCommand.inputRightArrow,
        .up: UIKeyCommand.inputUpArrow, .down: UIKeyCommand.inputDownArrow,
    ]

    private static let flags: [Modifier: UIKeyModifierFlags] = [
        .command: .command, .shift: .shift, .option: .alternate, .control: .control,
    ]

    private static func enter(_ field: UIKeyInput) {
        guard let line = field as? UITextField else {
            field.insertText("\n")
            return
        }
        if line.delegate?.textFieldShouldReturn?(line) != false {
            line.sendActions(for: .editingDidEndOnExit)
        }
    }

    /// Makes the next field in reading order, or the one before, the one being edited, as
    /// Tab does in a form.
    private static func moveFocus(from field: UIKeyInput, backward: Bool, nodes: [Node]) {
        let fields = nodes.compactMap { $0.object as? UIView }.filter { $0 is UITextInput }
        guard let index = fields.firstIndex(where: { $0 === field as AnyObject }) else { return }
        let next = backward ? index - 1 : index + 1
        guard fields.indices.contains(next) else { return }
        _ = fields[next].becomeFirstResponder()
    }

    private enum End { case start, end }

    private static func move(_ field: UIKeyInput, to end: End, extending: Bool) {
        guard let input = field as? UITextInput, let range = input.selectedTextRange else { return }
        let target = end == .end ? input.endOfDocument : input.beginningOfDocument
        let anchor = end == .end ? range.start : range.end
        input.selectedTextRange = input.textRange(from: extending ? anchor : target, to: target)
    }

    private static func move(_ field: UIKeyInput, by offset: Int, extending: Bool) {
        guard let input = field as? UITextInput, let range = input.selectedTextRange else { return }
        let moving = offset > 0 ? range.end : range.start
        guard let target = input.position(from: moving, offset: offset) else { return }
        let anchor = offset > 0 ? range.start : range.end
        input.selectedTextRange = input.textRange(from: extending ? anchor : target, to: target)
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
        move(field, to: .end, extending: false)
        var left = (field as? UITextInput).map { length(of: $0) } ?? Int.max
        while field.hasText, left > 0 {
            field.deleteBackward()
            left -= 1
        }
        return true
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
