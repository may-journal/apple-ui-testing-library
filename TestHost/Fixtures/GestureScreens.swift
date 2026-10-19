import SwiftUI

/// A photo that counts double taps and single taps apart.
struct DoubleTapScreen: View {
    @State private var doubles = 0
    @State private var singles = 0

    var body: some View {
        VStack {
            Text("Photo")
                .onTapGesture(count: 2) { doubles += 1 }
                .onTapGesture { singles += 1 }
            Text("Double taps: \(doubles)")
            Text("Taps: \(singles)")
        }
    }
}

/// A row whose context menu offers Copy and Delete.
struct ContextMenuScreen: View {
    @State private var chosen = "Nothing chosen"

    var body: some View {
        VStack {
            Text("Note")
                .contextMenu {
                    Button("Copy") { chosen = "Copied" }
                    Button("Delete") { chosen = "Deleted" }
                }
            Text(chosen)
        }
    }
}

/// A list whose first row has a Delete swipe action.
struct SwipeScreen: View {
    @State private var deleted = false

    var body: some View {
        VStack {
            Text(deleted ? "Milk deleted" : "Milk kept")
            List {
                Text("Milk").swipeActions { Button("Delete") { deleted = true } }
                Text("Bread")
            }
        }
    }
}

/// An item that drags as text, and a basket that holds what drops on it.
struct DragScreen: View {
    @State private var basket = ""

    var body: some View {
        VStack(spacing: 40) {
            Text("Milk").draggable("Milk")
            Text(basket.isEmpty ? "Basket empty" : "Basket: \(basket)")
                .dropDestination(for: String.self) { items, _ in
                    basket = items.joined(separator: ", ")
                    return !items.isEmpty
                }
        }
    }
}

/// A volume slider at 5 and a servings stepper at 3, each stepping by one.
struct AdjustScreen: View {
    @State private var volume = 5.0
    @State private var servings = 3

    var body: some View {
        VStack {
            Slider(value: $volume, in: 0...10, step: 1) { Text("Volume") }.namedOnMac("Volume")
            Stepper("Servings", value: $servings, in: 0...10).namedOnMac("Servings")
            Text("Volume \(Int(volume))")
            Text("Servings \(servings)")
        }
    }
}

extension View {
    /// Names a control for VoiceOver on a Mac, which reads a slider's or stepper's visible
    /// label as text apart from it; iOS names the control by its label already.
    func namedOnMac(_ name: String) -> some View {
        #if canImport(UIKit)
        self
        #else
        accessibilityLabel(name)
        #endif
    }
}

/// A card that says so while the pointer is over it.
struct HoverScreen: View {
    @State private var hovering = false

    var body: some View {
        VStack(spacing: 40) {
            Text("Card").onHover { hovering = $0 }
            Text(hovering ? "Card hovered" : "Card at rest")
        }
    }
}

/// A map that counts pinches in and pinches out apart, each as its magnify gesture ends.
struct PinchScreen: View {
    @State private var ins = 0
    @State private var outs = 0

    var body: some View {
        VStack(spacing: 40) {
            Text("Map")
                .frame(width: 200, height: 200)
                .contentShape(Rectangle())
                .gesture(
                    MagnifyGesture().onEnded { value in
                        if value.magnification < 1 { ins += 1 }
                        if value.magnification > 1 { outs += 1 }
                    })
            Text("Pinches in: \(ins)")
            Text("Pinches out: \(outs)")
        }
    }
}

/// A card that reports, as its drag gesture ends, how far it moved and whether it was flicked:
/// let go while still moving fast, so its predicted end lies well past where it stopped.
struct DragByScreen: View {
    @State private var report = "Not dragged"

    var body: some View {
        VStack(spacing: 40) {
            Text("Card")
                .frame(width: 200, height: 200)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture().onEnded { value in
                        let moved = value.translation
                        let ahead = value.predictedEndTranslation
                        let flung = hypot(ahead.width - moved.width, ahead.height - moved.height)
                        let distance =
                            "\(Int(moved.width.rounded())), \(Int(moved.height.rounded()))"
                        report = "\(flung > 100 ? "Flicked" : "Dragged") \(distance)"
                    })
            Text(report)
        }
    }
}
