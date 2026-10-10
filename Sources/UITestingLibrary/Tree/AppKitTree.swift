#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Reads the AppKit tree through the `NSAccessibility` protocol, as VoiceOver walks it.
/// SwiftUI's nodes answer the protocol's messages without adopting it, so every call goes
/// through dynamic lookup on `AnyObject`.
extension Backend {
    /// Every element VoiceOver would stop on in the window, depth first.
    static func nodes(in window: HostWindow) -> [Node] {
        var found: [AnyObject] = []
        if let root = window.window.contentView { collect(root, into: &found) }
        return found.map { Node(element: element(of: $0, in: window.window), object: $0) }
    }

    private static func collect(_ object: AnyObject, into found: inout [AnyObject]) {
        if let view = object as? NSView, view.isHiddenOrHasHiddenAncestor { return }
        let children = (object.accessibilityChildren?() ?? []).map { $0 as AnyObject }
        if object.isAccessibilityElement?() == true, children.isEmpty {
            found.append(object)
            return
        }
        for child in children { collect(child, into: &found) }
    }

    private static func element(of object: AnyObject, in window: NSWindow) -> Element {
        let frame = window.convertFromScreen(object.accessibilityFrame?() ?? .zero)
        let middle = CGPoint(x: frame.midX, y: frame.midY)
        let inside = window.contentView?.frame.contains(middle) ?? false
        return Element(
            label: object.accessibilityLabel?() ?? object.accessibilityTitle?() ?? "",
            value: object.accessibilityValue?().map { "\($0)" }, identifier: identifier(of: object),
            roles: roles(of: object),
            actions: object.accessibilityCustomActions?()?.map(\.name) ?? [],
            frame: frame, isOnScreen: !frame.isEmpty && inside)
    }

    private static func identifier(of object: AnyObject) -> String? {
        guard let identifier = object.accessibilityIdentifier?(), !identifier.isEmpty else {
            return nil
        }
        return identifier
    }

    private static let roleMap: [NSAccessibility.Role: Role] = [
        .button: .button, .link: .link, .staticText: .text, .image: .image,
        .textField: .textField, .textArea: .textField, .checkBox: .toggle, .slider: .adjustable,
        .incrementor: .adjustable,
    ]

    private static func roles(of object: AnyObject) -> Set<Role> {
        var roles = Set<Role>()
        if let role = object.accessibilityRole?().flatMap({ roleMap[$0] }) { roles.insert(role) }
        if object.accessibilitySubrole?() == .searchField { roles = [.searchField] }
        if object.isAccessibilitySelected?() == true { roles.insert(.selected) }
        return roles
    }
}
#endif
