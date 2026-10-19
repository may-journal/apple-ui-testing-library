import SwiftUI

/// An Add menu holding Import and Scan, and a line saying which ran.
struct MenuScreen: View {
    @State private var chosen = "Nothing chosen"

    var body: some View {
        VStack {
            Menu("Add") {
                Button("Import") { chosen = "Imported" }
                Button("Scan") { chosen = "Scanned" }
            }
            Text(chosen)
        }
    }
}

/// A navigation stack with the Add menu in its content and a More menu in its navigation bar,
/// holding Export and Print, and a line saying which ran.
struct BarMenuScreen: View {
    @State private var chosen = "Nothing chosen"

    var body: some View {
        NavigationStack {
            VStack {
                Menu("Add") {
                    Button("Import") { chosen = "Imported" }
                    Button("Scan") { chosen = "Scanned" }
                }
                Text(chosen)
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("More") {
                        Button("Export") { chosen = "Exported" }
                        Button("Print") { chosen = "Printed" }
                    }
                }
            }
        }
    }
}

/// A "…" Options menu choosing Detailed or Simple, under a line drawn in that choice, so
/// each choice draws the view around the menu again.
struct RedrawnMenuScreen: View {
    @State private var simple = false

    var body: some View {
        VStack {
            Text(simple ? "Simple row" : "Detailed row")
            Menu {
                Button("Detailed") { simple = false }
                Button("Simple") { simple = true }
            } label: {
                Image(systemName: "ellipsis")
            }
            .accessibilityLabel("Options")
        }
    }
}
