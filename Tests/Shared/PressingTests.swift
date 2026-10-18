import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0009: pressing keys and clearing a field, as user-event does.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Pressing {
        @Test func test0009_1() async throws {
            let screen = try Screen.render { EditingScreen() }
            let user = User(screen)
            try await user.sees(.text("Not submitted"))
            try await user.presses(.enter)
            try await user.sees(.text("Submitted: Milk"))
            try screen.close()
        }

        @Test func test0009_2() async throws {
            let screen = try Screen.render { ClearingScreen() }
            let user = User(screen)
            try await user.sees(.text("Note: Milk"))
            try await user.clears(.role(.textField, "Note"))
            try await user.sees(.text("Note empty"))
            try screen.close()
        }

        @Test func test0009_3() async throws {
            let screen = try Screen.render { EditingScreen() }
            let user = User(screen)
            try await user.sees(.text("Typed: Milk"))
            try await user.presses(.end)
            try await user.types(" bread")
            try await user.sees(.text("Typed: Milk bread"))
            try screen.close()
        }
    }
}
