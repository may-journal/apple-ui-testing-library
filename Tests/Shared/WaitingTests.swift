import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0004: waiting on a condition, never a fixed time.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Waiting {
        @Test func test0004_1() async throws {
            let screen = try Screen.render { DelayedScreen(delay: .milliseconds(400)) }
            let started = ContinuousClock.now
            try await User(screen, deadline: .seconds(3)).sees(.text("Loaded"))
            #expect(ContinuousClock.now - started < .seconds(3))
            try screen.close()
        }

        @Test func test0004_2() async throws {
            let screen = try Screen.render { Message(text: "Shown") }
            let started = ContinuousClock.now
            await #expect(throws: Failure.self) {
                try await User(screen, deadline: .milliseconds(300)).sees(.text("Never"))
            }
            let elapsed = ContinuousClock.now - started
            #expect(elapsed >= .milliseconds(300) && elapsed < .seconds(2))
            try screen.close()
        }

        @Test func test0004_3() async throws {
            let screen = try Screen.render { DelayedScreen(delay: .milliseconds(400)) }
            let user = User(screen, deadline: .seconds(3))
            try await user.sees(.text("Loading"))
            try await user.doesNotSee(.text("Loading"))
            try screen.close()
        }

        @Test func test0004_4() async throws {
            let screen = try Screen.render { ReloadScreen() }
            let user = User(screen)
            try await user.sees(.text("Before"))
            try await user.taps(.button("Reload"))
            let read = await user.reads().map(\.spoken)
            #expect(read.contains("After"))
            #expect(!read.contains("Before"))
            try screen.close()
        }

        @Test func test0004_5() async throws {
            let screen = try Screen.render { LongScreen() }
            let user = User(screen)
            let started = ContinuousClock.now
            for count in 1...10 {
                try await user.taps(.button("Count"))
                try await user.sees(.text("Count: \(count)"))
            }
            #expect(ContinuousClock.now - started < .seconds(5))
            try screen.close()
        }
    }
}
