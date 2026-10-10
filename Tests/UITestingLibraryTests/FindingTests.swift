import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0002: finding what is on screen, by role and label, text, then identifier.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Finding {
        @Test func test0002_1() async throws {
            let screen = try Screen.render { SharedLabelScreen() }
            let found = try await User(screen).sees(.button("Save"))
            #expect(found.has(.button))
            try screen.close()
        }

        @Test func test0002_2() async throws {
            let screen = try Screen.render { Message(text: "Welcome back") }
            let found = try await User(screen).sees(.text("Welcome back"))
            #expect(found.spoken == "Welcome back")
            try screen.close()
        }

        @Test func test0002_3() async throws {
            let screen = try Screen.render { TabsScreen() }
            let found = try await User(screen).sees(.role(.selected, "Week"))
            #expect(found.label == "Week")
            try screen.close()
        }

        @Test func test0002_4() async throws {
            let screen = try Screen.render { RowsScreen() }
            let user = User(screen, deadline: .milliseconds(500))
            try await user.sees(.text("Row 1"))
            try await user.doesNotSee(.text("Row 40"))
            try screen.close()
        }

        @Test func test0002_5() async throws {
            let screen = try Screen.render { TwinButtonsScreen() }
            let user = User(screen)
            try await user.taps(.identifier("add-bottom"))
            try await user.sees(.text("Bottom added"))
            try screen.close()
        }
    }
}
