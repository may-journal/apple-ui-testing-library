import SwiftUI

/// A long screen, nested deep, as a real app's root is: a counter on top, then rows of
/// sections, each row a title and a button, most of them drawn off screen.
struct LongScreen: View {
    @State private var count = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Button("Count") { count += 1 }
                Text("Count: \(count)")
                ForEach(1...10, id: \.self) { section in
                    LongSection(number: section)
                }
            }
        }
    }
}

/// One section of `LongScreen`: a heading and twenty rows, each a container of its own. A
/// row's text offers Archive, which takes the row away and moves the rest up.
private struct LongSection: View {
    let number: Int
    @State private var archived: Set<Int> = []

    var body: some View {
        VStack(spacing: 0) {
            Text("Section \(number)").accessibilityAddTraits(.isHeader)
            ForEach((1...20).filter { !archived.contains($0) }, id: \.self) { row in
                HStack {
                    Text("Row \(number).\(row)")
                        .accessibilityAction(named: "Archive") { archived.insert(row) }
                    Button("Open") {}
                }
                .frame(height: 44)
                .accessibilityElement(children: .contain)
            }
        }
        .accessibilityElement(children: .contain)
    }
}
