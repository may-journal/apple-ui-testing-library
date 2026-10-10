import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0001 on iOS: the phone and iPad layouts, which only the iOS host draws.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct PhoneShowing {
        @Test func test0001_1() async throws {
            let screen = try Screen.render { LayoutScreen() }
            try await User(screen).sees(.text("Phone layout"))
            try screen.close()
        }

        @Test func test0001_2() async throws {
            let screen = try Screen.render(size: .pad) { LayoutScreen() }
            try await User(screen).sees(.text("Pad layout"))
            try screen.close()
        }
    }
}
