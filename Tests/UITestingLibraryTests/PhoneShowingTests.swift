import Testing
import UITestingLibrary

@testable import TestHost

/// Requirement 0001 on iOS: the phone and iPad layouts, which only the iOS host draws.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct PhoneShowing {
        @Test func test0001_8() async throws {
            let phone = try Screen.render { LayoutScreen() }
            try await User(phone).sees(.text("Phone layout"))
            try phone.close()
            let pad = try Screen.render(size: .pad) { LayoutScreen() }
            try await User(pad).sees(.text("Pad layout"))
            try pad.close()
        }
    }
}
