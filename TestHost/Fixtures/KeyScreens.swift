import SwiftUI

/// Two fields: an empty one being edited, and a note holding "Milk" that is not.
struct ClearingScreen: View {
    @State private var item = ""
    @State private var note = "Milk"
    @FocusState private var editing: Bool

    var body: some View {
        VStack {
            TextField("Item", text: $item).focused($editing).accessibilityLabel("Item")
            TextField("Note", text: $note).accessibilityLabel("Note")
            Text(note.isEmpty ? "Note empty" : "Note: \(note)")
        }
        .onAppear { DispatchQueue.main.async { editing = true } }
    }
}

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

/// A field of many lines being edited, holding "Milk", in a view whose Send button answers
/// Command-Return.
struct ShortcutScreen: View {
    @State private var note = "Milk"
    @State private var sent = ""
    @FocusState private var editing: Bool

    var body: some View {
        VStack {
            TextField("Note", text: $note, axis: .vertical).focused($editing)
            Button("Send") { sent = note }.keyboardShortcut(.return, modifiers: .command)
            Text(sent.isEmpty ? "Not sent" : "Sent: \(sent)")
            Text(note.contains("\n") ? "Note has a new line" : "Note is one line")
        }
        .onAppear { DispatchQueue.main.async { editing = true } }
    }
}

/// A form of two fields, the first being edited, and a line naming the one being edited.
struct FormScreen: View {
    private enum Field { case first, second }
    @State private var first = ""
    @State private var second = ""
    @FocusState private var editing: Field?

    var body: some View {
        VStack {
            TextField("First", text: $first).focused($editing, equals: .first)
            TextField("Second", text: $second).focused($editing, equals: .second)
            Text(
                editing == .second
                    ? "Editing second" : editing == .first ? "Editing first" : "Editing none")
        }
        .onAppear { DispatchQueue.main.async { editing = .first } }
    }
}

/// A source field holding "Milk", being edited, then an empty target field.
struct ClipboardScreen: View {
    @State private var source = "Milk"
    @State private var target = ""
    @FocusState private var editing: Bool

    var body: some View {
        VStack {
            TextField("Source", text: $source).focused($editing).accessibilityLabel("Source")
            TextField("Target", text: $target).accessibilityLabel("Target")
            Text(source.isEmpty ? "Source empty" : "Source: \(source)")
            Text(target.isEmpty ? "Target empty" : "Target: \(target)")
        }
        .onAppear { DispatchQueue.main.async { editing = true } }
    }
}
