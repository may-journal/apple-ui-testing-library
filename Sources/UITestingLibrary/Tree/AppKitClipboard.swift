#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Drives the clipboard in the AppKit field being edited, as its Edit menu items do: each
/// command goes up the responder chain from the field.
extension Backend {
    /// Runs the clipboard command in the field being edited; whether a responder took it.
    static func edit(_ command: EditCommand, in window: HostWindow) -> Bool {
        guard let field = editing(in: window) else { return false }
        if command != .selectAll { Clipboard.keep() }
        return field.tryToPerform(
            editActions[command, default: #selector(NSText.paste(_:))], with: nil)
    }

    private static let editActions: [EditCommand: Selector] = [
        .selectAll: #selector(NSText.selectAll(_:)), .copy: #selector(NSText.copy(_:)),
        .cut: #selector(NSText.cut(_:)), .paste: #selector(NSText.paste(_:)),
    ]

    /// Puts `text` on the clipboard, as copying it elsewhere would.
    static func putOnClipboard(_ text: String) {
        Clipboard.keep()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

/// The general pasteboard as it was before a test's first clipboard step, put back as the
/// screen closes, so a test never leaves the person's clipboard changed.
@MainActor
enum Clipboard {
    private static var kept: [NSPasteboardItem]?

    /// Keeps what the clipboard holds now, once per screen.
    static func keep() {
        guard kept == nil else { return }
        kept = (NSPasteboard.general.pasteboardItems ?? []).map { item in
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) { copy.setData(data, forType: type) }
            }
            return copy
        }
    }

    /// Puts back what the clipboard held, if a step changed it.
    static func restore() {
        guard let kept else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects(kept)
        self.kept = nil
    }
}
#endif
