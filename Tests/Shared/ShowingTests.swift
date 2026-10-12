import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0001: reading a shown screen, the same on iOS and macOS.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct Showing {
        @Test func test0001_3() async throws {
            let screen = try Screen.render { GroceriesScreen() }
            let read = await User(screen).reads()
            #expect(read.map(\.spoken) == ["Groceries", "Milk", "Add"])
            #expect(read.first?.has(.heading) == true)
            try screen.close()
        }

        @Test func test0001_4() async throws {
            let screen = try Screen.render { SheetScreen() }
            let user = User(screen)
            try await user.taps(.button("Show details"))
            let read = await user.reads().map(\.spoken)
            #expect(read.contains("Details"))
            #expect(!read.contains("Base"))
            try screen.close()
        }

        @Test func test0001_5() async throws {
            let first = try Screen.render { Message(text: "First") }
            try await User(first).sees(.text("First"))
            let second = try Screen.render { Message(text: "Second") }
            let user = User(second)
            try await user.sees(.text("Second"))
            try await user.doesNotSee(.text("First"))
            try second.close()
        }

        @Test func test0001_7() async throws {
            let screen = try Screen.render { LongScreen() }
            let user = User(screen)
            try await user.sees(.button("Count"))
            let started = ContinuousClock.now
            for _ in 1...10 {
                let read = await user.reads().map(\.spoken)
                #expect(read.contains("Row 1.1"))
            }
            #expect(ContinuousClock.now - started < .milliseconds(800))
            try screen.close()
        }

        @Test func test0001_9() async throws {
            let screen = try Screen.render(look: Look(textSize: .accessibility3)) { PriceScreen() }
            let user = User(screen)
            let name = try await user.sees(.text("Oat milk"))
            let price = try await user.sees(.text("$3.49"))
            let apart = abs(price.frame.midY - name.frame.midY)
            #expect(
                apart >= name.frame.height, "price beside the name: \(price.frame), \(name.frame)")
            try screen.close()
        }

        @Test func test0001_10() async throws {
            let dark = try Screen.render(look: Look(appearance: .dark)) { AppearanceScreen() }
            try await User(dark).sees(.text("Dark appearance"))
            try dark.close()
            let light = try Screen.render(look: Look(appearance: .light)) { AppearanceScreen() }
            try await User(light).sees(.text("Light appearance"))
            try light.close()
        }
    }
}
