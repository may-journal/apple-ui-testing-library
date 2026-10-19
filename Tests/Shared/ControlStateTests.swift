import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0006: reading and acting on control state.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct ControlState {
        @Test func test0006_1() async throws {
            let screen = try Screen.render { RequiredItemScreen() }
            let button = try await User(screen).sees(.button("Save"))
            #expect(!button.isEnabled)
            try screen.close()
        }

        @Test func test0006_2() async throws {
            let screen = try Screen.render { RequiredItemScreen() }
            let user = User(screen)
            var failure: Failure?
            do {
                try await user.taps(.button("Save"))
            } catch let caught as Failure {
                failure = caught
            }
            #expect(failure?.message.contains("disabled") == true)
            #expect(failure?.description.contains("\"Save\" (button disabled)") == true)
            try await user.sees(.text("Not saved"))
            try screen.close()
        }

        @Test func test0006_3() async throws {
            let screen = try Screen.render { RequiredItemScreen() }
            let user = User(screen)
            try await user.types("Milk")
            let button = try await user.sees(.button("Save"))
            #expect(button.isEnabled)
            try await user.taps(.button("Save"))
            try await user.sees(.text("Saved"))
            try screen.close()
        }

        @Test func test0006_5() async throws {
            let screen = try Screen.render { DisabledNoteActionScreen() }
            let user = User(screen)
            let note = try await user.sees(.button("Note"))
            #expect(!note.isEnabled)
            #expect(note.actions.contains("Archive"))

            var failure: Failure?
            do {
                try await user.chooses("Archive", on: .button("Note"))
            } catch let caught as Failure {
                failure = caught
            }
            #expect(failure?.message.contains("disabled") == true)
            #expect(failure?.description.contains("\"Note\" (button disabled)") == true)
            try await user.sees(.text("Not archived"))
            try screen.close()
        }
    }
}
