import SwiftUI

/// The key window the host app lends to a test: a `UIWindow` on iOS, an `NSWindow` on
/// macOS (ADR 0006). Nothing in it animates, and on a Mac it draws off every display, so a
/// test never shows on screen or takes focus (ADR 0011).
@MainActor
public final class HostWindow {
    /// The size the root view is laid out at, in points.
    public let size: ScreenSize

    /// Whether no display shows any part of the window. A Mac running the tests keeps it off
    /// every display; an iPhone or iPad has only the one it shows on.
    public var isOffScreen: Bool { Backend.isOffScreen(self) }

    #if canImport(UIKit)
    let window: UIWindow

    init<Content: View>(size: ScreenSize, look: Look, content: Content) throws {
        self.size = size
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard let scene = scenes.first else { throw HostWindowError.noScene }
        Backend.moveOffScreen(scene)
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
        // Key within the scene only; the scene's Mac window stays off every display.
        window.makeKeyAndVisible()
    }

    /// Hides the window and drops its root.
    func close() {
        Backend.closeMenu()
        Backend.endPointer()
        window.endEditing(true)
        window.isHidden = true
        window.rootViewController = nil
    }
    #else
    let window: NSWindow

    init<Content: View>(size: ScreenSize, look: Look, content: Content) throws {
        self.size = size
        window = HeadlessWindow(
            contentRect: CGRect(origin: Backend.offScreenOrigin, size: size.points),
            styleMask: [.titled], backing: .buffered, defer: false)
        let host = HeadlessHostingView(
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
        window.setFrameOrigin(Backend.offScreenOrigin)
        // Ordered in, so it lays out and answers accessibility, but behind the app's other
        // windows, off every display, and never activating the app.
        window.orderBack(nil)
        window.contentView?.layoutSubtreeIfNeeded()
    }

    /// Ends any sheet, then closes the window and drops its root.
    func close() {
        Backend.closeMenu()
        Backend.endPointer()
        if let sheet = window.attachedSheet { window.endSheet(sheet) }
        window.contentView = nil
        window.orderOut(nil)
    }
    #endif
}

#if canImport(AppKit) && !canImport(UIKit)
/// A hosting view a test drives without the window server. It takes the first click, since
/// the app is never frontmost, and it keeps a drag SwiftUI starts in process: the window
/// server would move it with the person's own pointer (ADR 0011).
private final class HeadlessHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func beginDraggingSession(
        with items: [NSDraggingItem], event: NSEvent, source: any NSDraggingSource
    ) -> NSDraggingSession {
        Backend.keepDrag(items, from: source)
        // AppKit names no initializer for a session; this one is never driven.
        return unsafeDowncast(
            (NSDraggingSession.self as NSObject.Type).init(), to: NSDraggingSession.self)
    }

    @available(macOS 27, *)
    override func beginDraggingSession(
        items: [NSDraggingItem], gesture: NSGestureRecognizer, source: any NSDraggingSource
    ) -> NSDraggingSession? {
        Backend.keepDrag(items, from: source)
        return nil
    }
}

/// A window that keeps the test's content size and its place off every display, and that
/// counts as key without the app coming forward. SwiftUI fits a hosting view's window to
/// its content as it lays out, whatever its sizing options, which would clip a toolbar's
/// items into an overflow menu.
private final class HeadlessWindow: NSWindow {
    private var contentSize: CGSize?

    override init(
        contentRect: NSRect, styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        contentSize = contentRect.size
    }

    /// Key and main as a person's front window is, so controls, fields and drags answer as
    /// they do there, while the app stays in the background.
    override var isKeyWindow: Bool { true }
    override var isMainWindow: Bool { true }

    /// AppKit pulls a window back onto a display; this one stays where it was placed.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }

    /// Any frame keeps the content size and its place off every display, wherever AppKit
    /// would cascade or center it; a title bar that grows a toolbar still grows.
    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
        guard let contentSize else { return super.setFrame(frameRect, display: flag) }
        var fixed = frameRect
        fixed.size = self.frameRect(forContentRect: CGRect(origin: .zero, size: contentSize)).size
        fixed.origin = Backend.offScreenOrigin
        super.setFrame(fixed, display: flag)
    }
}
#endif

/// Why a window could not be made.
enum HostWindowError: Error {
    /// The host app has no window scene to lend.
    case noScene
}
