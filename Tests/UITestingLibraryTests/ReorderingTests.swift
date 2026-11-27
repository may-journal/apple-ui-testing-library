import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0013: a list row's reorder handle, which only an iOS list in edit mode draws.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Reordering {
        @Test func test0013_1() async throws {
            let screen = try Screen.render { ReorderScreen() }
            let user = User(screen)
            try await user.sees(.text("Order: Eggs, Milk, Bread"))
            try await user.drags(.button("Reorder Eggs"), to: .button("Reorder Bread"))
            try await user.sees(.text("Order: Milk, Bread, Eggs"))
            try screen.close()
        }
    }
}
