#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Reads and drives the menu a control opens, as VoiceOver does once it moves into the
/// menu. A press opens the menu, which AppKit tracks in its own run loop mode while the main
/// queue keeps running; while it is open, its items are all a person reads, and a press on
/// one runs it and closes the menu.
extension Backend {
    /// The items of the open menu, in order, or nil when no menu is open.
    static func menuNodes() -> [Node]? {
        OpenMenu.watch()
        guard let menu = OpenMenu.shared.menu else { return nil }
        return menu.items.filter { !$0.isHidden && !$0.isSeparatorItem }.map { item in
            Node(object: item, isOnScreen: true) {
                Element(label: item.title, roles: [.button])
            }
        }
    }

    /// Runs the menu item and closes its menu; whether the object was an enabled item. An item
    /// that opens a submenu runs nothing, so it answers false, as on iOS.
    static func choosesMenuItem(_ object: AnyObject) -> Bool {
        guard let item = object as? NSMenuItem, item.isEnabled, !item.hasSubmenu,
            let menu = item.menu
        else {
            return false
        }
        menu.performActionForItem(at: menu.index(of: item))
        closeMenu()
        return true
    }

    /// Closes the open menu, if any, without choosing an item.
    static func closeMenu() {
        OpenMenu.shared.menu?.cancelTracking()
        OpenMenu.shared.menu = nil
    }
}

/// The menu tracking now, told by AppKit's begin and end notifications.
@MainActor
private final class OpenMenu: NSObject {
    static let shared = OpenMenu()
    private static var watching = false
    var menu: NSMenu?

    static func watch() {
        guard !watching else { return }
        watching = true
        let center = NotificationCenter.default
        center.addObserver(
            shared, selector: #selector(began(_:)), name: NSMenu.didBeginTrackingNotification,
            object: nil)
        center.addObserver(
            shared, selector: #selector(ended(_:)), name: NSMenu.didEndTrackingNotification,
            object: nil)
    }

    /// A menu that begins once its screen closed is cancelled at once, so the app can quit.
    @objc private func began(_ note: Notification) {
        menu = note.object as? NSMenu
        if Screen.open == nil { Backend.closeMenu() }
    }

    @objc private func ended(_ note: Notification) {
        if menu === note.object as? NSMenu { menu = nil }
    }
}
#endif
