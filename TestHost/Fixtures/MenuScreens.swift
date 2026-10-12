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
