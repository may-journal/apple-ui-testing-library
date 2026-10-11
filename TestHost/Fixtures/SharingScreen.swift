#if canImport(UIKit)
import SwiftUI
import UITestingLibraryShareDestination

/// Generic system-share fixture. Mutations alter the delivered outputs for negative proof.
struct SharingScreen: View {
    @State private var sharing = false
    @State private var confirming = false

    var body: some View {
        if ProcessInfo.processInfo.arguments.contains("--scroll-share") {
            ScrollView {
                VStack {
                    ForEach(0..<30) { number in Text("Item \(number)").frame(height: 50) }
                    shareButton
                }
            }
        } else {
            shareButton
        }
    }

    private var shareButton: some View {
        Button("Share Alex") { confirming = true }
            .confirmationDialog(
                "Share Alex's card?", isPresented: $confirming, titleVisibility: .visible
            ) {
                Button("Share card") { sharing = true }
            }
            .sheet(isPresented: $sharing) { ShareSheet() }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let arguments = ProcessInfo.processInfo.arguments
        let recipient = arguments.contains("--wrong-image") ? "Morgan" : "Taylor"
        let extra = arguments.contains("--extra-match") ? "\nMorgan" : ""
        let image = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 300)).image { _ in
            UIColor.white.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 600, height: 300)).fill()
            let text = "Alex gives to \(recipient)\(extra)"
            text.draw(
                in: CGRect(x: 30, y: 50, width: 540, height: 220),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 36), .foregroundColor: UIColor.black,
                ])
        }
        let message = arguments.contains("--wrong-message") ? "Morgan's card" : "Alex's card"
        var items: [Any] = [image, message]
        if arguments.contains("--missing-image") { items = [message] }
        if arguments.contains("--malformed-image") { items = [Data("broken image".utf8), message] }
        return UIActivityViewController(
            activityItems: items,
            applicationActivities: [LocalShareDestination()])
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
#endif
