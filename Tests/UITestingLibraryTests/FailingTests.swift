import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0005: reading a failure as what a person would have seen.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Failing {
        @Test func test0005_1() async throws {
            let screen = try Screen.render { GroceriesScreen() }
            let failure = await failing {
                try await User(screen, deadline: .milliseconds(200)).sees(.text("Eggs"))
            }
            #expect(failure?.report.onScreen.map(\.spoken) == ["Groceries", "Milk", "Add"])
            #expect(failure?.description.contains("Milk") == true)
            try screen.close()
        }

        @Test func test0005_2() async throws {
            let screen = try Screen.render { Message(text: "Just text") }
            let failure = await failing { try await User(screen).taps(.text("Just text")) }
            #expect(
                failure?.message.hasPrefix("Nothing tappable has the label text \"Just text\"")
                    == true)
            try screen.close()
        }

        @Test func test0005_3() async throws {
            let screen = try Screen.render { NoteScreen() }
            let failure = await failing {
                try await User(screen).chooses("Delete", on: .text("Note"))
            }
            let message = failure?.message ?? ""
            #expect(message.contains("Archive") && message.contains("Pin"), "\(message)")
            #expect(message.hasSuffix("not \"Delete\""), "\(message)")
            try screen.close()
        }

        @Test func test0005_4() async throws {
            let screen = try Screen.render { EmptyScreen() }
            let user = User(screen, deadline: .milliseconds(300))
            let failure = await failing { try await user.doesNotSee(.text("Anything")) }
            #expect(failure?.message.hasSuffix("the screen read empty") == true)
            #expect(throws: Failure.self) { try screen.close() }
        }

        @Test func test0005_5() async throws {
            let screen = try Screen.render { Message(text: "Shown") }
            let user = User(screen, deadline: .milliseconds(200))
            let line = UInt(#line) + 1
            let failure = await failing { try await user.taps(.button("Missing")) }
            #expect(failure?.location.line == line)
            #expect(failure?.location.filePath == #filePath)
            try screen.close()
        }

        /// The failure `look` throws, or nil when it passes.
        private func failing(_ look: () async throws -> Void) async -> Failure? {
            do {
                try await look()
                return nil
            } catch {
                return error as? Failure
            }
        }
    }
}
