import SwiftUI

/// A required item enables saving only once the person enters it.
struct RequiredItemScreen: View {
    @State private var item = ""
    @State private var saved = false
    @FocusState private var editing: Bool

    var body: some View {
        VStack {
            TextField("Item", text: $item).focused($editing)
            Button("Save") { saved = true }.disabled(item.isEmpty)
            Text(saved ? "Saved" : "Not saved")
        }
        .onAppear { DispatchQueue.main.async { editing = true } }
    }
}

/// Plain text and a button that share one label.
struct SharedLabelScreen: View {
    @State private var saved = false

    var body: some View {
        VStack {
            Text("Save")
            Button("Save") { saved = true }
            if saved { Text("Saved") }
        }
    }
}

/// Two buttons with one label, told apart by identifier only.
struct TwinButtonsScreen: View {
    @State private var added = ""

    var body: some View {
        VStack {
            Button("Add") { added = "Top added" }.accessibilityIdentifier("add-top")
            Button("Add") { added = "Bottom added" }.accessibilityIdentifier("add-bottom")
            Text(added)
        }
    }
}

/// A button that counts its taps.
struct CounterScreen: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Button("Count") { count += 1 }
            Text("Count: \(count)")
        }
    }
}

/// A note offering two custom actions, as a hold would.
struct NoteScreen: View {
    @State private var archived = false

    var body: some View {
        VStack {
            Text("Note")
                .accessibilityAction(named: "Archive") { archived = true }
                .accessibilityAction(named: "Pin") {}
            if archived { Text("Archived") }
        }
    }
}

/// A field already being edited, echoing what is typed.
struct FieldScreen: View {
    @State private var item = ""
    @FocusState private var editing: Bool

    var body: some View {
        VStack {
            TextField("Item", text: $item).focused($editing)
            Text("Typed: \(item)")
        }
        // SwiftUI on the Mac drops a focus set while the field first appears, so the focus
        // waits one turn of the main queue, as a Mac app's own code does.
        .onAppear { DispatchQueue.main.async { editing = true } }
    }
}

/// A front page with a link that pushes a detail page.
struct StackScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Front page")
                NavigationLink("Details") { Text("Detail page") }
            }
        }
    }
}

/// A draft a person deletes through a confirmation dialog, then is told so in an alert.
struct DeleteScreen: View {
    @State private var confirms = false
    @State private var tells = false
    @State private var deleted = false

    var body: some View {
        VStack {
            Text(deleted ? "Deleted" : "Draft")
            Button("Delete") { confirms = true }
        }
        .confirmationDialog("Delete the draft?", isPresented: $confirms, titleVisibility: .visible)
        {
            Button("Delete draft", role: .destructive) { tells = true }
        }
        .alert("Draft deleted", isPresented: $tells) {
            Button("Done") { deleted = true }
        }
    }
}
