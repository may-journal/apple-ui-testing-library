import SwiftUI

/// Says "Loading" until its delay passes, then "Loaded".
struct DelayedScreen: View {
    let delay: Duration
    @State private var loaded = false

    var body: some View {
        Text(loaded ? "Loaded" : "Loading")
            .task {
                try? await Task.sleep(for: delay)
                loaded = true
            }
    }
}

/// A button that redraws the screen when tapped.
struct ReloadScreen: View {
    @State private var reloaded = false

    var body: some View {
        VStack {
            Button("Reload") { reloaded = true }
            Text(reloaded ? "After" : "Before")
        }
    }
}
