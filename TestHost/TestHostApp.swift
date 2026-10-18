import SwiftUI

/// The app that hosts the package's own tests, on iOS and on macOS. Fixture screens join
/// as requirement tests land.
@main
struct TestHostApp: App {
    var body: some Scene {
        WindowGroup {
            HostRoot()
        }
        #if os(macOS)
        // Tests draw in windows of their own, off every display; the app opens none on screen.
        .defaultLaunchBehavior(.suppressed)
        #endif
    }
}

private struct HostRoot: View {
    var body: some View {
        #if canImport(UIKit)
        if ProcessInfo.processInfo.arguments.contains("--system-sharing") {
            SharingScreen()
        } else {
            Text("Test host")
        }
        #else
        Text("Test host")
        #endif
    }
}
