import SwiftUI

/// The key window the host app lends to a test: a `UIWindow` on iOS, an `NSWindow` on
/// macOS (ADR 0006). Nothing in it animates.
@MainActor
public final class HostWindow {
    /// The size the root view is laid out at, in points.
    public let size: ScreenSize

    #if canImport(UIKit)
    let window: UIWindow

    init<Content: View>(size: ScreenSize, look: Look, content: Content) throws {
        self.size = size
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard let scene = scenes.first else { throw HostWindowError.noScene }
        window = UIWindow(windowScene: scene)
        window.frame = CGRect(origin: .zero, size: size.points)
        UIView.setAnimationsEnabled(false)
        let host = UIHostingController(
            rootView: content.transaction { $0.disablesAnimations = true })
        host.traitOverrides.horizontalSizeClass = size.isRegularWidth ? .regular : .compact
        host.traitOverrides.verticalSizeClass = .regular
        if let textSize = look.textSize {
            host.traitOverrides.preferredContentSizeCategory = UIContentSizeCategory(textSize)
        }
        if let appearance = look.appearance {
            host.traitOverrides.userInterfaceStyle = UIUserInterfaceStyle(appearance)
        }
        window.rootViewController = host
        window.makeKeyAndVisible()
    }

    /// Hides the window and drops its root.
    func close() {
        Backend.closeMenu()
        window.endEditing(true)
        window.isHidden = true
        window.rootViewController = nil
    }
    #else
    let window: NSWindow

    init<Content: View>(size: ScreenSize, look: Look, content: Content) throws {
        self.size = size
        window = FixedSizeWindow(
            contentRect: CGRect(origin: .zero, size: size.points), styleMask: [.titled],
            backing: .buffered,
            defer: false)
        let host = NSHostingView(
            rootView: content.transaction { $0.disablesAnimations = true }
                .transformEnvironment(\.dynamicTypeSize) { $0 = look.textSize ?? $0 })
        window.appearance = look.appearance.flatMap {
            NSAppearance(named: $0 == .dark ? .darkAqua : .aqua)
        }
        // The window keeps the test's size; the hosting view never resizes it to fit.
        host.sizingOptions = []
        window.contentView = host
        window.contentMinSize = size.points
        window.contentMaxSize = size.points
        window.makeKeyAndOrderFront(nil)
        window.contentView?.layoutSubtreeIfNeeded()
    }

    /// Ends any sheet, then closes the window and drops its root.
    func close() {
        Backend.closeMenu()
        if let sheet = window.attachedSheet { window.endSheet(sheet) }
        window.contentView = nil
        window.orderOut(nil)
    }
    #endif
}

#if canImport(AppKit) && !canImport(UIKit)
/// A window that keeps the test's content size. SwiftUI fits a hosting view's window to its
/// content as it lays out, whatever its sizing options, which would clip a toolbar's items
/// into an overflow menu.
private final class FixedSizeWindow: NSWindow {
    private var contentSize: CGSize?

    override init(
        contentRect: NSRect, styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        contentSize = contentRect.size
    }

    /// Any frame keeps the content size; a title bar that grows a toolbar still grows.
    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
        guard let contentSize else { return super.setFrame(frameRect, display: flag) }
        var fixed = frameRect
        fixed.size = self.frameRect(forContentRect: CGRect(origin: .zero, size: contentSize)).size
        fixed.origin.y = frameRect.maxY - fixed.height
        super.setFrame(fixed, display: flag)
    }
}
#endif

/// Why a window could not be made.
enum HostWindowError: Error {
    /// The host app has no window scene to lend.
    case noScene
}
