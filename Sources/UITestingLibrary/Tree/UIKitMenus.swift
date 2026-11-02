#if canImport(UIKit)
import UIKit

/// Reads and drives the menu a control opens, as VoiceOver does once it moves into the
/// menu. A tap opens the menu through the control's context menu interaction, and a tap
/// on an item runs it and closes the menu.
extension Backend {
    /// Remembers the menu interaction of the control under the element, so the next read
    /// can ask for its menu. A disabled control opens nothing, and the result says whether
    /// this opened the menu.
    static func opensMenu(under object: NSObject, in window: UIWindow) -> Bool {
        let point = window.convert(object.accessibilityActivationPoint, from: nil)
        var view = window.hitTest(point, with: nil)
        while let current = view, !(current is UIControl) { view = current.superview }
        guard let control = view as? UIControl, control.isEnabled,
            control.isContextMenuInteractionEnabled
        else { return false }
        OpenMenu.shared.opening(control.contextMenuInteraction)
        guard control.showsMenuAsPrimaryAction else { return false }
        control.performPrimaryAction()
        return true
    }

    /// The items of the open menu, in order, or nil when no menu is open.
    static func menuNodes() -> [Node]? {
        guard let menu = OpenMenu.shared.shown() else { return nil }
        return items(of: menu).map { item in
            Node(object: item, isOnScreen: true) {
                Element(
                    label: item.title, roles: [.button],
                    isEnabled: (item as? UIMenuLeaf)?.attributes.contains(.disabled) != true)
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

    /// Goes back out of the open menu, as a person's escape does; whether a menu was open.
    /// Its items answer no escape, so the menu itself closes.
    static func goBackOutOfMenu() -> Bool {
        guard OpenMenu.shared.shown() != nil else { return false }
        closeMenu()
        return true
    }

    /// Whether a cancelled Mac menu is still unwinding. The Mac ignores a tap on a menu button
    /// that comes before the cancelled menu's tracking ends, so every act settles after it.
    static var isMenuClosing: Bool { OpenMenu.shared.isClosing }

    /// Opens `menu` as a hold opens a context menu, without drawing it. Its items become
    /// what a read holds until an item runs or the menu closes.
    static func holdMenu(_ menu: UIMenu) {
        OpenMenu.shared.hold(menu)
    }

    /// Closes the open menu, if any, without choosing an item.
    static func closeMenu() {
        OpenMenu.shared.close()
    }
}

/// The menu a tapped control opened, kept until it closes because asking again on a Mac
/// can close it. A Mac tracks the menu in its own run loop mode, so closing it cancels
/// that tracking by name.
@MainActor
private final class OpenMenu: NSObject {
    static let shared = OpenMenu()
    private var interaction: UIContextMenuInteraction?
    private var menu: UIMenu?
    private var native: NSObject?
    /// The Mac menu this cancelled, until its tracking ends. Only a menu cancelled here
    /// counts, so another menu in the app never holds an act.
    private var cancelled: NSObject?
    /// A context menu a hold opened without drawing it.
    private var held: UIMenu?

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

    func hold(_ menu: UIMenu) {
        close()
        held = menu
    }

    /// The open menu, asking UIKit only until it answers. A control taken off screen takes
    /// its menu with it.
    func shown() -> UIMenu? {
        if let held { return held }
        if interaction?.view?.window == nil { (interaction, menu) = (nil, nil) }
        if menu == nil {
            interaction?.updateVisibleMenu { visible in
                menu = visible
                return visible
            }
        }
        return menu
    }

    var isClosing: Bool { cancelled != nil }

    func close() {
        held = nil
        interaction?.dismissMenu()
        (interaction, menu) = (nil, nil)
        if let native { cancelled = native }
        native?.perform(NSSelectorFromString("cancelTracking"))
        native = nil
    }

    /// A Mac menu that begins after its menu was closed is cancelled at once.
    @objc private func began(_ note: Notification) {
        native = note.object as? NSObject
        if interaction == nil { close() }
    }

    @objc private func ended(_ note: Notification) {
        let object = note.object as? NSObject
        if native != nil, native === object { (interaction, menu, native) = (nil, nil, nil) }
        if cancelled === object { cancelled = nil }
    }
}
#endif
