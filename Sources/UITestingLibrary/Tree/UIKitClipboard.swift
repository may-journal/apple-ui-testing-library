#if canImport(UIKit)
import UIKit

/// Drives the clipboard in the UIKit field being edited, as its edit menu does, sending
/// each command up the responder chain.
extension Backend {
    /// Runs the clipboard command in the field being edited; whether a responder took it.
    static func edit(_ command: EditCommand, in window: HostWindow) -> Bool {
        guard let field = editing(in: window.window) as? UIResponder else { return false }
        if command != .selectAll { Clipboard.keep() }
        return UIApplication.shared.sendAction(
            editActions[command, default: #selector(UIResponderStandardEditActions.paste(_:))],
            to: field, from: nil, for: nil)
    }

    private static let editActions: [EditCommand: Selector] = [
        .selectAll: #selector(UIResponderStandardEditActions.selectAll(_:)),
        .copy: #selector(UIResponderStandardEditActions.copy(_:)),
        .cut: #selector(UIResponderStandardEditActions.cut(_:)),
        .paste: #selector(UIResponderStandardEditActions.paste(_:)),
    ]

    /// Puts `text` on the clipboard, as copying it elsewhere would.
    static func putOnClipboard(_ text: String) {
        Clipboard.keep()
        UIPasteboard.general.string = text
    }
}

/// The general pasteboard from before a test's first clipboard step, put back as the
/// screen closes, so a test never changes it.
@MainActor
enum Clipboard {
    private static var kept: [[String: Any]]?

    /// Keeps what the clipboard holds now, once per screen.
    static func keep() {
        if kept == nil { kept = UIPasteboard.general.items }
    }

    /// Puts back what the clipboard held, if a step changed it.
    static func restore() {
        guard let kept else { return }
        UIPasteboard.general.items = kept
        self.kept = nil
    }
}
#endif
