import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0010: watching what a person notices beyond one read of the screen.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Watching {
        @Test func test0010_1() async throws {
            let screen = try Screen.render { DelayedScreen(delay: .milliseconds(300)) }
            let user = User(screen)
            try await user.doesNotSee(.text("Loaded"))
            await #expect(throws: Failure.self) {
                try await user.neverSees(.text("Loaded"), for: .seconds(2))
            }
            let started = ContinuousClock.now
            try await user.neverSees(.text("Loading"), for: .milliseconds(300))
            #expect(ContinuousClock.now - started >= .milliseconds(300))
            try screen.close()
        }

        @Test func test0010_2() async throws {
            let screen = try Screen.render { FreezeScreen(stall: .milliseconds(600)) }
            let user = User(screen)
            try await user.staysResponsive(under: .milliseconds(300)) {
                try await user.taps(.button("Count"))
            }
            let failure = await #expect(throws: Failure.self) {
                try await user.staysResponsive(under: .milliseconds(300)) {
                    try await user.taps(.button("Count slowly"))
                }
            }
            #expect(failure?.message.contains("stalled for") == true)
            try screen.close()
        }

        @Test func test0010_3() async throws {
            let screen = try Screen.render { ShareScreen() }
            let user = User(screen, deadline: .seconds(1))
            await #expect(throws: Failure.self) { try await user.seesShareSheet() }
            try await user.taps(.button("Share"))
            try await user.seesShareSheet()
            try screen.close()
        }
    }
}
