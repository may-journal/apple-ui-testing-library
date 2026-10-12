import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0003: doing what a person does, through what VoiceOver offers.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Acting {
        @Test func test0003_1() async throws {
            let screen = try Screen.render { CounterScreen() }
            let user = User(screen)
            try await user.taps(.button("Count"))
            try await user.sees(.text("Count: 1"))
            try screen.close()
        }

        @Test func test0003_2() async throws {
            let screen = try Screen.render { NoteScreen() }
            let user = User(screen)
            try await user.chooses("Archive", on: .text("Note"))
            try await user.sees(.text("Archived"))
            try screen.close()
        }

        @Test func test0003_3() async throws {
            let screen = try Screen.render { FieldScreen() }
            let user = User(screen)
            try await user.types("Milk")
            try await user.sees(.text("Typed: Milk"))
            try screen.close()
        }

        @Test func test0003_4() async throws {
            let screen = try Screen.render { RowsScreen() }
            let user = User(screen)
            try await user.doesNotSee(.text("Row 12"))
            try await user.scrolls(.down)
            try await user.sees(.text("Row 12"))
            try screen.close()
        }

        @Test func test0003_5() async throws {
            let screen = try Screen.render { StackScreen() }
            let user = User(screen)
            try await user.taps(.button("Details"))
            try await user.sees(.text("Detail page"))
            try await user.goesBack()
            try await user.sees(.text("Front page"))
            try screen.close()
        }

        @Test func test0003_6() async throws {
            let screen = try Screen.render { DeleteScreen() }
            let user = User(screen)
            try await user.taps(.button("Delete"))
            try await user.sees(.text("Delete the draft?"))
            try await user.taps(.button("Delete draft"))
            try await user.sees(.text("Draft deleted"))
            try await user.taps(.button("Done"))
            try await user.sees(.text("Deleted"))
            try screen.close()
        }

        @Test func test0003_7() async throws {
            let screen = try Screen.render { MenuScreen() }
            let user = User(screen)
            try await user.taps(.button("Add"))
            try await user.sees(.button("Import"))
            let read = await user.reads().map(\.spoken)
            #expect(read == ["Import", "Scan"])
            try await user.taps(.button("Import"))
            try await user.sees(.text("Imported"))
            try screen.close()
        }
    }
}
