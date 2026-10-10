import SwiftUI

/// The app that hosts the package's own tests, on iOS and on macOS. Fixture screens join
/// as requirement tests land.
@main
struct TestHostApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Test host")
        }
    }
}
