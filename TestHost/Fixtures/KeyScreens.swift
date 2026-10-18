import SwiftUI

/// A one-line field already being edited, holding "Milk" with every word selected, as a Mac
/// selects a field's words when it gains focus. Return submits what it holds.
struct EditingScreen: View {
    @State private var item = "Milk"
    @State private var selection: TextSelection?
    @State private var submitted = ""
    @FocusState private var editing: Bool

    var body: some View {
        VStack {
            TextField("Item", text: $item, selection: $selection)
                .focused($editing)
                .onSubmit { submitted = item }
            Text(item.isEmpty ? "Empty" : "Typed: \(item)")
            Text(submitted.isEmpty ? "Not submitted" : "Submitted: \(submitted)")
        }
        // As in FieldScreen, the focus waits one turn of the main queue on the Mac.
        .onAppear {
            DispatchQueue.main.async {
                editing = true
                selection = TextSelection(range: item.startIndex..<item.endIndex)
            }
        }
    }
}
