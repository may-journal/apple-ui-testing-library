#if canImport(UIKit)
import UIKit

/// Reads and drives the menu a control opens, as VoiceOver does once it moves into the
/// menu. A tap opens the menu through the control's context menu interaction; while it is
/// open, its items are all a person reads, and a tap on one runs it and closes the menu.
extension Backend {
    /// Remembers the menu interaction of the control under the element, if it has one, so
    /// the next read can ask for the menu it opens.
    static func watchMenu(under object: NSObject, in window: UIWindow) {
        let point = window.convert(object.accessibilityActivationPoint, from: nil)
        var view = window.hitTest(point, with: nil)
        while let current = view, !(current is UIControl) { view = current.superview }
        guard let control = view as? UIControl, control.isContextMenuInteractionEnabled else {
            return
        }
        OpenMenu.shared.opening(control.contextMenuInteraction)
    }

    /// The items of the open menu, in order, or nil when no menu is open.
    static func menuNodes() -> [Node]? {
        guard let menu = OpenMenu.shared.shown() else { return nil }
        return items(of: menu).map { item in
            Node(object: item, isOnScreen: true) {
                Element(label: item.title, roles: [.button])
            }
        }
    }

    /// An inline section's items join its menu's, as a person sees them in one list.
    private static func items(of menu: UIMenu) -> [UIMenuElement] {
        menu.children.flatMap { child -> [UIMenuElement] in
            guard let section = child as? UIMenu, section.options.contains(.displayInline) else {
                return [child]
            }
            return items(of: section)
        }
    }

    /// Runs the menu item and closes its menu; whether the object was an enabled item.
    static func choosesMenuItem(_ object: NSObject) -> Bool {
        guard let leaf = object as? UIMenuLeaf, !leaf.attributes.contains(.disabled) else {
            return false
        }
        leaf.performWithSender(nil, target: nil)
        closeMenu()
        return true
    }

    /// Closes the open menu, if any, without choosing an item.
    static func closeMenu() {
        OpenMenu.shared.close()
    }
}

/// The menu a tapped control opened. UIKit answers the visible menu once: on a Mac running
/// the iOS app, asking again finds nothing and can close the Mac's menu. So the menu is
/// asked for until it answers, then kept until it closes.
///
/// That Mac draws the menu itself and tracks it in its own run loop mode, while the main
/// queue keeps running. Closing UIKit's menu leaves the Mac's tracking, so it is cancelled
/// by name, as a click outside would; a person closing it ends the menu here too. On iOS
/// itself the Mac's notifications never post.
@MainActor
private final class OpenMenu: NSObject {
    static let shared = OpenMenu()
    private var interaction: UIContextMenuInteraction?
    private var menu: UIMenu?
    private var native: NSObject?

    override private init() {
        super.init()
        let center = NotificationCenter.default
        center.addObserver(
            self, selector: #selector(began(_:)),
            name: Notification.Name("NSMenuDidBeginTrackingNotification"), object: nil)
        center.addObserver(
            self, selector: #selector(ended(_:)),
            name: Notification.Name("NSMenuDidEndTrackingNotification"), object: nil)
    }

    func opening(_ interaction: UIContextMenuInteraction?) {
        self.interaction = interaction
        menu = nil
    }

    /// The open menu, asking UIKit only until it answers.
    func shown() -> UIMenu? {
        if menu == nil {
            interaction?.updateVisibleMenu { visible in
                menu = visible
                return visible
            }
        }
        return menu
    }

    func close() {
        interaction?.dismissMenu()
        (interaction, menu) = (nil, nil)
        native?.perform(NSSelectorFromString("cancelTracking"))
        native = nil
    }

    /// A Mac menu that begins after its menu was closed is cancelled at once.
    @objc private func began(_ note: Notification) {
        native = note.object as? NSObject
        if interaction == nil { close() }
    }

    @objc private func ended(_ note: Notification) {
        guard native != nil, native === note.object as? NSObject else { return }
        (interaction, menu, native) = (nil, nil, nil)
    }
}
#endif
