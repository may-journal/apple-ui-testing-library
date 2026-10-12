import SwiftUI

/// Says which appearance it is drawn in.
struct AppearanceScreen: View {
    @Environment(\.colorScheme) private var appearance

    var body: some View {
        Text(appearance == .dark ? "Dark appearance" : "Light appearance")
    }
}

/// A name and its price side by side, stacked once the text size is an accessibility size,
/// so both stay on screen.
struct PriceScreen: View {
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        let layout =
            textSize.isAccessibilitySize ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
        layout {
            Text("Oat milk")
            Text("$3.49")
        }
    }
}
