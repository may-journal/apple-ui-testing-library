import Foundation
import SwiftUI

/// A button that holds the main thread for `stall` before it counts, as slow work on the
/// main thread does, beside one that counts at once.
struct FreezeScreen: View {
    let stall: Duration
    @State private var count = 0

    var body: some View {
        VStack {
            Button("Count") { count += 1 }
            Button("Count slowly") {
                Thread.sleep(forTimeInterval: stall / .seconds(1))
                count += 1
            }
            Text("Count: \(count)")
        }
    }
}

/// A note shared through the system share sheet: UIKit's activity view controller on iOS,
/// AppKit's sharing service picker on the Mac.
struct ShareScreen: View {
    @State private var sharing = false

    var body: some View {
        #if canImport(UIKit)
        Button("Share") { sharing = true }
            .sheet(isPresented: $sharing) { ActivitySheet() }
        #else
        Button("Share") {
            guard let view = NSApp.windows.last(where: \.isVisible)?.contentView else { return }
            NSSharingServicePicker(items: ["Note"])
                .show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        }
        #endif
    }
}

#if canImport(UIKit)
private struct ActivitySheet: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: ["Note"], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
#endif
