import SwiftUI

/// A root view drawn in a key window of the host app. One screen is open at a time;
/// rendering another closes it (ADR 0005). Closing runs the canary (ADR 0004).
@MainActor
public final class Screen {
    /// The window the root view is drawn in.
    public let window: HostWindow
    /// Whether any read of this screen found an element.
    public internal(set) var canary = Canary.readNothing
    /// The screen open now, if any.
    public private(set) static var open: Screen?

    private init(window: HostWindow) {
        self.window = window
    }

    /// Draws `content` as the app's root at `size` and `look`, closing any screen still open.
    public static func render<Content: View>(
        size: ScreenSize = .phone, look: Look = .system,
        file: StaticString = #filePath, line: UInt = #line,
        @ViewBuilder content: () -> Content
    ) throws -> Screen {
        open?.window.close()
        open = nil
        do {
            let screen = try Timing.measure(.render) {
                Screen(window: try HostWindow(size: size, look: look, content: content()))
            }
            open = screen
            return screen
        } catch {
            throw Failure(
                "The host app has no window scene to draw in",
                report: ScreenReport(onScreen: [], offScreen: []),
                location: SourceLocation(file: file, line: line))
        }
    }

    /// Hides the window and releases the root, then fails if nothing was ever read.
    public func close(
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        window.close()
        if Screen.open === self { Screen.open = nil }
        try Canary.check(self, location: SourceLocation(file: file, line: line))
    }
}
