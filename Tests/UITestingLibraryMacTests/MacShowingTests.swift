import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0001 on the Mac: showing the app in an AppKit window (ADR 0006).
extension UITestingLibraryTests {
    @MainActor
    @Suite struct MacShowing {
        @Test func test0001_6() async throws {
            let screen = try Screen.render { LayoutScreen() }
            try await User(screen).sees(.text("Mac layout"))
            try screen.close()
        }
    }
}
