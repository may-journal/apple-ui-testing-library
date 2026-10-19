import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0013: pinches to a chosen scale, and pinches held partway, through a
/// trackpad's magnify events made in process.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Pinching {
        @Test func test0013_1() async throws {
            let screen = try Screen.render { PinchScaleScreen() }
            let user = User(screen)
            try await user.pinches(.out, .text("Photo"), to: 1.25)
            try await user.sees(.text("Ended at 1.25"))
            try await user.pinches(.in, .text("Photo"), to: 0.85)
            try await user.sees(.text("Ended at 0.85"))
            #expect(screen.window.isOffScreen)
            try screen.close()
        }

        @Test func test0013_2() async throws {
            let screen = try Screen.render { PinchScaleScreen() }
            let user = User(screen)
            let pinch = try await user.holdsPinch(.in, .text("Photo"), to: 0.8)
            try await user.sees(.text("Pinching at 0.80"))
            try await user.sees(.text("Not ended"))
            try await pinch.releases()
            try screen.close()
        }

        @Test func test0013_3() async throws {
            let screen = try Screen.render { PinchScaleScreen() }
            let user = User(screen)
            let pinch = try await user.holdsPinch(.out, .text("Photo"), to: 1.1)
            try await pinch.releases()
            try await user.sees(.text("Ended at 1.10"))
            #expect(screen.window.isOffScreen)
            try screen.close()
        }

        @Test func test0013_4() async throws {
            let screen = try Screen.render { PinchScaleScreen() }
            let user = User(screen)
            let failure = await #expect(throws: Failure.self) {
                try await user.pinches(.in, .text("Photo"), to: 1.2)
            }
            #expect(failure?.message.contains("needs a scale between 0 and 1, not 1.2") == true)
            try await user.sees(.text("Not pinched"))
            try screen.close()
        }

        @Test func test0013_5() async throws {
            let held = try Screen.render { PinchScaleScreen() }
            _ = try await User(held).holdsPinch(.in, .text("Photo"), to: 0.8)
            try held.close()
            let screen = try Screen.render { PinchScaleScreen() }
            let user = User(screen)
            try await user.pinches(.in, .text("Photo"), to: 0.7)
            try await user.sees(.text("Ended at 0.70"))
            try screen.close()
        }
    }
}
