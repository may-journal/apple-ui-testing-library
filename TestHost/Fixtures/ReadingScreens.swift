import SwiftUI

/// A heading, a line, and a button, in reading order.
struct GroceriesScreen: View {
    var body: some View {
        VStack {
            Text("Groceries").accessibilityAddTraits(.isHeader)
            Text("Milk")
            Button("Add") {}
        }
    }
}

/// A base with a button that covers it with a sheet.
struct SheetScreen: View {
    @State private var showsDetails = false

    var body: some View {
        VStack {
            Text("Base")
            Button("Show details") { showsDetails = true }
        }
        .sheet(isPresented: $showsDetails) {
            Text("Details")
        }
    }
}

/// Two tabs, one of which VoiceOver calls selected.
struct TabsScreen: View {
    var body: some View {
        HStack {
            Text("Day")
            Text("Week").accessibilityAddTraits(.isSelected)
        }
    }
}

/// Numbered rows, far more than fit on a screen.
struct RowsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(1...40, id: \.self) { number in
                    Text("Row \(number)").frame(height: 80)
                }
            }
        }
    }
}
