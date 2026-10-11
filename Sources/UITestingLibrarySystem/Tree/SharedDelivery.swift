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
                    + "Messages: \(messages)",
                report: ScreenReport(onScreen: [], offScreen: []),
                location: SourceLocation(file: file, line: line))
        }
        let missing = containing.filter { !text.localizedCaseInsensitiveContains($0) }
        let unexpected = excluding.filter { text.localizedCaseInsensitiveContains($0) }
        guard messages == [message], images.count == 1, missing.isEmpty, unexpected.isEmpty else {
            throw Failure(
                "Shared delivery differs. Messages: \(messages). Images: \(images.count). "
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
        let activities = application.staticTexts.matching(
            NSPredicate(format: "label == %@", "Local Test Destination"))
        let activity = try finds(
            activities, description: "local share activity", file: file, line: line)
        activity.tap()
        let receipt = try sees(
            .identifier("UITestingLibrary.sharedReceipt"), file: file, line: line)
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

    /// Dismisses the receipt, or the system sheet's Close button on cancellation.
    public func dismissShare(
        _ query: Query = .button("Done"), file: StaticString = #filePath, line: UInt = #line
    ) throws { try taps(query, file: file, line: line) }
}
