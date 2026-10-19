import CoreGraphics
import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0012: drags by a distance, slowly or as a flick, through pointer events made
/// in process.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Dragging {
        @Test func test0012_1() async throws {
            let screen = try Screen.render { DragByScreen() }
            let user = User(screen)
            try await user.drags(.text("Card"), by: CGVector(dx: 120, dy: 40), speed: .slow)
            try await user.sees(.text("Dragged 120, 40"))
            #expect(screen.window.isOffScreen)
            try screen.close()
        }

        @Test func test0012_2() async throws {
            let screen = try Screen.render { DragByScreen() }
            let user = User(screen)
            try await user.drags(.text("Card"), by: CGVector(dx: -60, dy: 0), speed: .flick)
            try await user.sees(.text("Flicked -60, 0"))
            try await user.swipes(.right, .text("Card"))
            try await user.sees(.text("Flicked 100, 0"))
            #expect(screen.window.isOffScreen)
            try screen.close()
        }
    }
}
