import SwiftUI

/// The key window the host app lends to a test: a `UIWindow` on iOS, an `NSWindow` on
/// macOS (ADR 0006). Nothing in it animates.
@MainActor
public final class HostWindow {
    /// The size the root view is laid out at, in points.
    public let size: ScreenSize

    #if canImport(UIKit)
    let window: UIWindow

    init<Content: View>(size: ScreenSize, content: Content) throws {
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
        window.rootViewController = host
        window.makeKeyAndVisible()
    }

    /// Hides the window and drops its root.
    func close() {
        window.endEditing(true)
        window.isHidden = true
        window.rootViewController = nil
    }
    #else
    let window: NSWindow

    init<Content: View>(size: ScreenSize, content: Content) throws {
        self.size = size
        window = NSWindow(
            contentRect: CGRect(origin: .zero, size: size.points), styleMask: [.titled],
            backing: .buffered,
            defer: false)
        let host = NSHostingView(rootView: content.transaction { $0.disablesAnimations = true })
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
        if let sheet = window.attachedSheet { window.endSheet(sheet) }
        window.contentView = nil
        window.orderOut(nil)
    }
    #endif
}

/// Why a window could not be made.
enum HostWindowError: Error {
    /// The host app has no window scene to lend.
    case noScene
}
