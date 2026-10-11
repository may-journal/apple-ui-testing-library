import Foundation
import UITestingLibrary
import Vision
import XCTest

/// Evidence decoded from a local destination after UIKit delivered the share.
public struct SharedDelivery: Sendable {
    public let images: [Data]
    public let messages: [String]

    /// Recognizes pixels from the received image, not the sender's accessibility tree.
    public func visibleText(inImage index: Int = 0) throws -> [String] {
        guard images.indices.contains(index) else { throw DeliveryError("Missing image \(index)") }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        try VNImageRequestHandler(data: images[index]).perform([request])
        return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
    }

    /// Checks exact message and OCR phrases; a wrong image fails even with a right message.
    public func check(
        message: String, containing: [String], excluding: [String],
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        let text: String
        do {
            text = try visibleText().joined(separator: "\n")
        } catch {
            throw Failure(
                "Cannot read shared image: \(error). Images: \(images.count). "
                    + "Messages: \(messages.joined(separator: " | "))",
                report: ScreenReport(onScreen: [], offScreen: []),
                location: SourceLocation(file: file, line: line))
        }
        let missing = containing.filter { !text.localizedCaseInsensitiveContains($0) }
        let unexpected = excluding.filter { text.localizedCaseInsensitiveContains($0) }
        guard messages == [message], images.count == 1, missing.isEmpty, unexpected.isEmpty else {
            throw Failure(
                "Shared delivery differs. Messages: \(messages.joined(separator: " | ")). "
                    + "Images: \(images.count). "
                    + "Missing: \(missing). Unexpected: \(unexpected). OCR: \(text)",
                report: ScreenReport(
                    onScreen: [Element(label: "Received image text", value: text)],
                    offScreen: []),
                location: SourceLocation(file: file, line: line))
        }
    }
}

private struct DeliveryError: Error, CustomStringConvertible {
    let description: String
    init(_ message: String) { description = message }
}

extension SystemSession {
    /// Selects the local activity from the actual system share sheet.
    public func receivesShare(
        file: StaticString = #filePath, line: UInt = #line
    ) throws -> SharedDelivery {
        let receipt = try receivedReceipt(file: file, line: line)
        struct Payload: Decodable {
            let images: [String]
            let messages: [String]
        }
        guard let value = receipt.value as? String, let bytes = value.data(using: .utf8),
            let payload = try? JSONDecoder().decode(Payload.self, from: bytes)
        else {
            throw failure(
                "Local destination did not expose a valid receipt", file: file, line: line)
        }
        let images = payload.images.compactMap { Data(base64Encoded: $0) }
        guard images.count == payload.images.count else {
            throw failure("Local destination delivered invalid image bytes", file: file, line: line)
        }
        return SharedDelivery(images: images, messages: payload.messages)
    }

    private func receivedReceipt(file: StaticString, line: UInt) throws -> XCUIElement {
        let receipts = application.descendants(matching: .any).matching(
            NSPredicate(format: "identifier == %@", "UITestingLibrary.sharedReceipt"))
        let activities = application.staticTexts.matching(
            NSPredicate(format: "label == %@", "Local Test Destination"))
        var previousFrame: CGRect?
        var delivered: XCUIElement?
        let condition = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                if let receipt = receipts.allElementsBoundByIndex.first(where: \.isHittable) {
                    delivered = receipt
                    return true
                }
                let visible = activities.allElementsBoundByIndex.filter(\.isHittable)
                guard visible.count == 1, let activity = visible.first else { return false }
                let frame = activity.frame
                // System sheets can move titles after becoming hittable on a cold launch.
                // Act only at a stable frame; retry only this local destination if it stays open.
                if previousFrame == frame { activity.tap() }
                previousFrame = frame
                return false
            }, object: nil)
        guard XCTWaiter.wait(for: [condition], timeout: timeout) == .completed,
            let delivered
        else { throw failure("Local share did not deliver a receipt", file: file, line: line) }
        return delivered
    }

    /// Dismisses the receipt, or the system sheet's Close button on cancellation.
    public func dismissShare(
        _ query: Query = .button("Done"), file: StaticString = #filePath, line: UInt = #line
    ) throws { try taps(query, file: file, line: line) }
}
