import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0011: gestures beyond a tap, in process, through each platform's own entry
/// points.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Gesturing {
        @Test func test0011_1() async throws {
            let screen = try Screen.render { DoubleTapScreen() }
            let user = User(screen)
            try await user.doubleTaps(.text("Photo"))
            try await user.sees(.text("Double taps: 1"))
            try await user.sees(.text("Taps: 0"))
            try screen.close()
        }

        @Test func test0011_2() async throws {
            let screen = try Screen.render { ContextMenuScreen() }
            let user = User(screen)
            try await user.longPresses(.text("Note"))
            #expect(await user.reads().map(\.spoken) == ["Copy", "Delete"])
            try await user.taps(.button("Delete"))
            try await user.sees(.text("Deleted"))
            try screen.close()
        }

        @Test func test0011_3() async throws {
            let screen = try Screen.render { SwipeScreen() }
            let user = User(screen)
            try await user.doesNotSee(.button("Delete"))
            #if os(macOS)
            // AppKit shows a row's swipe actions only for a trackpad's touches, which no event
            // made in process carries, so the swipe fails clearly (ADR 0011).
            await #expect(throws: Failure.self) { try await user.swipes(.left, .text("Milk")) }
            #else
            try await user.swipes(.left, .text("Milk"))
            try await user.sees(.button("Delete"))
            #endif
            try screen.close()
        }

        @Test func test0011_4() async throws {
            let screen = try Screen.render { DragScreen() }
            let user = User(screen)
            try await user.drags(.text("Milk"), to: .text("Basket empty"))
            try await user.sees(.text("Basket: Milk"))
            try screen.close()
        }

        @Test func test0011_5() async throws {
            let screen = try Screen.render { AdjustScreen() }
            let user = User(screen)
            try await user.adjusts(.up, .role(.adjustable, "Volume"))
            try await user.adjusts(.up, .role(.adjustable, "Servings"))
            try await user.sees(.text("Volume 6"))
            try await user.sees(.text("Servings 4"))
            try await user.adjusts(.down, .role(.adjustable, "Volume"))
            try await user.adjusts(.down, .role(.adjustable, "Servings"))
            try await user.sees(.text("Volume 5"))
            try await user.sees(.text("Servings 3"))
            try screen.close()
        }

        @Test func test0011_6() async throws {
            let screen = try Screen.render { HoverScreen() }
            let user = User(screen)
            try await user.sees(.text("Card at rest"))
            try await user.hovers(.text("Card"))
            try await user.sees(.text("Card hovered"))
            try await user.unhovers(.text("Card"))
            try await user.sees(.text("Card at rest"))
            try screen.close()
        }

        @Test func test0011_7() async throws {
            let screen = try Screen.render { DoubleTapScreen() }
            let user = User(screen)
            #expect(screen.window.isOffScreen)
            try await user.doubleTaps(.text("Photo"))
            try await user.sees(.text("Double taps: 1"))
            #expect(screen.window.isOffScreen)
            try screen.close()
        }
    }
}
