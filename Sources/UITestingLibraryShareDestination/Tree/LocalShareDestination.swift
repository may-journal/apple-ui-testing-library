#if canImport(UIKit)
import UIKit

/// Add only in test builds to UIActivityViewController.applicationActivities.
/// UIKit resolves the sender's items for this destination before calling prepare.
@MainActor
public final class LocalShareDestination: UIActivity, @unchecked Sendable {
    override public var activityType: UIActivity.ActivityType? {
        UIActivity.ActivityType("org.may-journal.testing.local-receiver")
    }
    override public var activityTitle: String? { "Local Test Destination" }
    override public var activityImage: UIImage? { UIImage(systemName: "tray.and.arrow.down") }
    private var items: [Any] = []

    override public func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        activityItems.contains { $0 is UIImage || $0 is Data || $0 is String }
    }

    override public func prepare(withActivityItems activityItems: [Any]) {
        let delivered = ActivityItems(values: activityItems)
        MainActor.assumeIsolated { items = delivered.values }
    }

    override public var activityViewController: UIViewController? {
        MainActor.assumeIsolated {
            let receipt = ReceiptController()
            receipt.items = items
            receipt.finished = { [weak self] in self?.activityDidFinish(true) }
            return receipt
        }
    }
}

// UIKit invokes activity callbacks on the main thread; assumeIsolated checks that contract.
private struct ActivityItems: @unchecked Sendable {
    let values: [Any]
}

/// This view exports only received bytes, never an app model or renderer input.
@MainActor
private final class ReceiptController: UIViewController {
    var items: [Any] = []
    var finished: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let images = items.compactMap { item -> String? in
            let bytes = (item as? UIImage)?.pngData() ?? (item as? Data)
            return bytes?.base64EncodedString()
        }
        let messages = items.compactMap { $0 as? String }
        let receipt: [String: Any] = ["images": images, "messages": messages]
        let payload = (try? JSONSerialization.data(withJSONObject: receipt)) ?? Data()
        let evidence = UILabel()
        evidence.text = "Received \(images.count) image(s) and \(messages.count) message(s)"
        evidence.accessibilityIdentifier = "UITestingLibrary.sharedReceipt"
        evidence.accessibilityValue = String(data: payload, encoding: .utf8)
        evidence.numberOfLines = 0
        let picture = UIImageView(image: items.compactMap { $0 as? UIImage }.first)
        picture.contentMode = .scaleAspectFit
        let message = UILabel()
        message.text = messages.joined(separator: "\n")
        message.numberOfLines = 0
        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.addAction(UIAction { [weak self] _ in self?.finished?() }, for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [evidence, picture, message, done])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}
#endif
