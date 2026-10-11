#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Reads the AppKit tree through the `NSAccessibility` protocol, as VoiceOver walks it.
/// SwiftUI's nodes answer the protocol's messages without adopting it, so every call goes
/// through dynamic lookup on `AnyObject`.
extension Backend {
    /// Every element VoiceOver would stop on in the front window, depth first. A sheet is
    /// its own window over the screen, and only the sheet is read while it is up.
    static func nodes(in window: HostWindow) -> [Node] {
        let front = frontWindow(of: window.window)
        var found: [AnyObject] = []
        if let root = front.contentView { collect(root, into: &found) }
        return found.map { node(of: $0, in: front) }
    }

    /// The window a person reads: the deepest sheet attached to `window`, or `window` itself.
    static func frontWindow(of window: NSWindow) -> NSWindow {
        var front = window
        while let sheet = front.attachedSheet { front = sheet }
        return front
    }

    /// Walks the tree as VoiceOver does. A control or text whose role VoiceOver stops on is
    /// never asked for its children, since SwiftUI builds a text's link children on request.
    private static func collect(_ object: AnyObject, into found: inout [AnyObject]) {
        if let view = object as? NSView, view.isHiddenOrHasHiddenAncestor { return }
        let isElement = object.isAccessibilityElement?() == true
        if isElement, stopsOn(object) {
            found.append(object)
            return
        }
        let children = (object.accessibilityChildren?() ?? []).map { $0 as AnyObject }
        if isElement, children.isEmpty, !isEmptyGroup(object) {
            found.append(object)
            return
        }
        for child in children { collect(child, into: &found) }
    }

    /// Whether the object has a role this reader maps, as a control or text does.
    private static func stopsOn(_ object: AnyObject) -> Bool {
        guard let role = text(of: object, "accessibilityRole") else { return false }
        return roleMap[NSAccessibility.Role(rawValue: role)] != nil
    }

    /// Whether the object is a group with nothing in it, nothing to say and nothing to offer,
    /// such as a hosting view whose root exposes nothing. VoiceOver never stops on one.
    private static func isEmptyGroup(_ object: AnyObject) -> Bool {
        text(of: object, "accessibilityRole") == NSAccessibility.Role.group.rawValue
            && text(of: object, "accessibilityLabel") == nil
            && text(of: object, "accessibilityTitle") == nil
            && attribute(of: object, "accessibilityValue") == nil
            && text(of: object, "accessibilityIdentifier") == nil
            && (object.accessibilityCustomActions?() ?? []).isEmpty
    }

    /// The element, with its frame read first, so one drawn off screen waits to be read.
    private static func node(of object: AnyObject, in window: NSWindow) -> Node {
        let frame = window.convertFromScreen(object.accessibilityFrame?() ?? .zero)
        let middle = CGPoint(x: frame.midX, y: frame.midY)
        let inside = window.contentView?.frame.contains(middle) ?? false
        let isOnScreen = !frame.isEmpty && inside
        return Node(object: object, isOnScreen: isOnScreen) {
            element(of: object, frame: frame, isOnScreen: isOnScreen)
        }
    }

    private static func element(of object: AnyObject, frame: CGRect, isOnScreen: Bool)
        -> Element
    {
        let roles = roles(of: object)
        var label = text(of: object, "accessibilityLabel") ?? text(of: object, "accessibilityTitle")
        var value = attribute(of: object, "accessibilityValue").map { "\($0)" }
        // Static text carries its words as its value; VoiceOver says them as the label, as
        // UIKit's text does.
        if label == nil, !roles.isDisjoint(with: [.text, .heading]) {
            (label, value) = (value, nil)
        }
        return Element(
            label: label ?? "", value: value,
            identifier: text(of: object, "accessibilityIdentifier"), roles: roles,
            actions: object.accessibilityCustomActions?()?.map(\.name) ?? [],
            frame: frame, isOnScreen: isOnScreen)
    }

    /// An attribute as the node answers it, untyped. A typed dynamic call can pick a
    /// declaration returning `String?` and trap when a node answers a number, as a scroller's
    /// value does.
    private static func attribute(of object: AnyObject, _ key: String) -> Any? {
        let selector = NSSelectorFromString(key)
        guard object.responds(to: selector) else { return nil }
        return object.perform(selector)?.takeUnretainedValue()
    }

    /// A string attribute, or nil when it is empty or not a string.
    private static func text(of object: AnyObject, _ key: String) -> String? {
        guard let text = attribute(of: object, key) as? String, !text.isEmpty else { return nil }
        return text
    }

    private static let roleMap: [NSAccessibility.Role: Set<Role>] = [
        .button: [.button], .link: [.link], .staticText: [.text], .image: [.image],
        NSAccessibility.Role(rawValue: "AXHeading"): [.heading, .text], .textField: [.textField],
        .textArea: [.textField],
        .checkBox: [.toggle], .slider: [.adjustable], .incrementor: [.adjustable],
    ]

    private static func roles(of object: AnyObject) -> Set<Role> {
        let role = text(of: object, "accessibilityRole").map(NSAccessibility.Role.init(rawValue:))
        var roles = role.flatMap { roleMap[$0] } ?? []
        let subrole = text(of: object, "accessibilitySubrole")
        if subrole == NSAccessibility.Subrole.searchField.rawValue { roles = [.searchField] }
        if object.isAccessibilitySelected?() == true { roles.insert(.selected) }
        return roles
    }
}
#endif
