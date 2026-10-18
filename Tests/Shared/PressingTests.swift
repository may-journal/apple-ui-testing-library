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

        @Test func test0009_4() async throws {
            let screen = try Screen.render { ShortcutScreen() }
            let user = User(screen)
            try await user.sees(.text("Not sent"))
            try await user.presses(.enter, with: [.command])
            try await user.sees(.text("Sent: Milk"))
            try await user.sees(.text("Note is one line"))
            try screen.close()
        }

        @Test func test0009_5() async throws {
            let screen = try Screen.render { FormScreen() }
            let user = User(screen)
            try await user.sees(.text("Editing first"))
            try await user.tabs()
            try await user.sees(.text("Editing second"))
            try await user.tabs(backward: true)
            try await user.sees(.text("Editing first"))
            try screen.close()
        }

        @Test func test0009_6() async throws {
            let screen = try Screen.render { ClipboardScreen() }
            let user = User(screen)
            // A Mac selects a field's words as it gains focus; End leaves nothing selected.
            try await user.presses(.end)
            try await user.selectsAll(in: .role(.textField, "Source"))
            try await user.copies()
            try await user.tabs()
            try await user.pastes()
            try await user.sees(.text("Source: Milk"))
            try await user.sees(.text("Target: Milk"))
            try screen.close()
        }

        @Test func test0009_7() async throws {
            let screen = try Screen.render { ClipboardScreen() }
            let user = User(screen)
            // A Mac selects a field's words as it gains focus; End leaves nothing selected.
            try await user.presses(.end)
            try await user.selectsAll(in: .role(.textField, "Source"))
            try await user.cuts()
            try await user.sees(.text("Source empty"))
            try await user.pastes()
            try await user.sees(.text("Source: Milk"))
            try screen.close()
        }
    }
}
