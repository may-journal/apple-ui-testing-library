#if canImport(UIKit)
import UIKit

/// Reads the UIKit tree as VoiceOver walks it.
extension Backend {
    /// Every element VoiceOver would stop on in the window, depth first. Behind a modal
    /// view, such as a sheet, nothing counts.
    static func nodes(in window: HostWindow) -> [Node] {
        var found: [NSObject] = []
        collect(window.window, into: &found)
        return found.map { Node(element: element(of: $0, in: window.window), object: $0) }
    }

    private static func collect(_ object: NSObject, into found: inout [NSObject]) {
        if isHidden(object) { return }
        if object.isAccessibilityElement {
            found.append(object)
            return
        }
        for child in children(of: object) { collect(child, into: &found) }
    }

    /// Whether VoiceOver skips the object and all it holds. A Mac running the iOS app draws
    /// an alert natively, and UIKit hides its own copy then; the copy still holds the title
    /// and buttons VoiceOver reads and presses, so it counts.
    private static func isHidden(_ object: NSObject) -> Bool {
        if let view = object as? UIView {
            if ProcessInfo.processInfo.isiOSAppOnMac, view.next is UIAlertController {
                return false
            }
            if view.isHidden || view.alpha < 0.01 { return true }
        }
        return object.accessibilityElementsHidden
    }

    /// An element's children as VoiceOver walks them; a modal child hides its siblings.
    private static func children(of object: NSObject) -> [NSObject] {
        if let listed = object.accessibilityElements as? [NSObject], !listed.isEmpty {
            return listed
        }
        guard let view = object as? UIView else { return [] }
        // A modal view hides what lies behind it, not what lies in front: a sheet's dimming
        // view is modal, and the sheet sits above it.
        if let index = view.subviews.lastIndex(where: {
            $0.accessibilityViewIsModal && !$0.isHidden
        }) {
            return Array(view.subviews[index...])
        }
        return view.subviews
    }

    private static func element(of object: NSObject, in window: UIWindow) -> Element {
        let frame = window.convert(object.accessibilityFrame, from: nil)
        let middle = CGPoint(x: frame.midX, y: frame.midY)
        return Element(
            label: object.accessibilityLabel ?? "", value: object.accessibilityValue,
            identifier: identifier(of: object),
            roles: roles(of: object),
            actions: object.accessibilityCustomActions?.map(\.name) ?? [], frame: frame,
            isOnScreen: !frame.isEmpty && window.bounds.contains(middle))
    }

    /// The identifier, which SwiftUI's elements answer without adopting the protocol for it.
    private static func identifier(of object: NSObject) -> String? {
        let key = "accessibilityIdentifier"
        guard object.responds(to: NSSelectorFromString(key)) else { return nil }
        return object.value(forKey: key) as? String
    }

    private static let traitRoles: [(UIAccessibilityTraits, Role)] = [
        (.button, .button), (.link, .link), (.header, .heading), (.image, .image),
        (.staticText, .text), (.searchField, .searchField), (.adjustable, .adjustable),
        (.toggleButton, .toggle), (.selected, .selected),
    ]

    private static func roles(of object: NSObject) -> Set<Role> {
        let traits = object.accessibilityTraits
        var roles = Set(traitRoles.filter { traits.contains($0.0) }.map(\.1))
        if object is UIKeyInput, !roles.contains(.searchField) { roles.insert(.textField) }
        return roles
    }
}

extension NSObject {
    /// The container VoiceOver reads this element in, if it names one.
    var accessibilityParent: NSObject? {
        let key = "accessibilityContainer"
        return responds(to: NSSelectorFromString(key)) ? value(forKey: key) as? NSObject : nil
    }
}
#endif
