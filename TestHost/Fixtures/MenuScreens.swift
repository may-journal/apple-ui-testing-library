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
