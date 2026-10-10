import SwiftUI

/// One line of text, the smallest screen a test can read.
struct Message: View {
    let text: String

    var body: some View {
        Text(text)
    }
}

/// A screen that exposes nothing to VoiceOver.
struct EmptyScreen: View {
    var body: some View {
        Color.clear
    }
}

/// Says which layout it took: a phone's, an iPad's, or a Mac's.
struct LayoutScreen: View {
    #if os(macOS)
    var body: some View {
        Text("Mac layout")
    }
    #else
    @Environment(\.horizontalSizeClass) private var width

    var body: some View {
        Text(width == .regular ? "Pad layout" : "Phone layout")
    }
    #endif
}
