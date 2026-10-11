import UITestingLibrary
import XCTest

/// Siri's visible answer, captured from its own accessibility tree.
public struct SiriAnswer: Sendable {
    public let phrase: String
    public let observed: [String]

    /// Fails if Siri exposed another person's private answer.
    public func excludes(
        _ text: String, file: StaticString = #filePath, line: UInt = #line
    ) throws {
        guard !observed.contains(where: { $0.contains(text) }) else {
            throw SiriFailure(
                kind: .response, phrase: phrase, observed: observed,
                message: "Siri exposed forbidden text \"\(text)\"",
                location: SourceLocation(file: file, line: line))
        }
    }
}

/// A setup failure is distinct from an observed answer that fails the app assertion.
public struct SiriFailure: Error, CustomStringConvertible {
    public enum Kind: Sendable, Equatable {
        /// Empty transcript or unsupported runner: no answer can be checked.
        case setup
        /// Unexpected text whose source could be Siri, setup, routing, or the app.
        case indeterminate
        /// Forbidden text in an answer whose expected transcript was already found.
        case response
    }
    public let kind: Kind
    public let phrase: String
    public let observed: [String]
    public let message: String
    public let location: SourceLocation

    public var description: String {
        "\(message) (\(location))\nPhrase: \(phrase)\nObserved Siri text: \(observed)"
    }
}

/// A captured transcript. Validation alone does not prove Siri ran an app intent.
public struct SiriTranscript: Sendable {
    public let phrase: String
    public let observed: [String]

    public init(phrase: String, observed: [String]) {
        self.phrase = phrase
        self.observed = observed
    }

    /// Requires the expected transcript; unexpected nonempty text has unknown provenance.
    public func expecting(
        _ answer: String, file: StaticString = #filePath, line: UInt = #line
    ) throws -> SiriAnswer {
        guard observed.contains(answer) else {
            throw failure(answer, location: SourceLocation(file: file, line: line))
        }
        return SiriAnswer(phrase: phrase, observed: observed)
    }

    func failure(_ answer: String, location: SourceLocation) -> SiriFailure {
        SiriFailure(
            kind: observed.isEmpty ? .setup : .indeterminate,
            phrase: phrase, observed: observed,
            message: observed.isEmpty
                ? "Siri returned no accessible answer; check Siri and shortcut setup"
                : "Expected stable Siri answer \"\(answer)\"; check setup, service and routing",
            location: location)
    }
}

extension SystemSession {
    /// Sends recognized speech through Siri, then waits for the expected visible answer.
    /// This needs an iOS UI test runner, with Siri enabled and the app's shortcuts installed.
    /// It checks the displayed transcript; it does not record synthesized audio.
    public func askSiri(
        _ phrase: String, expecting answer: String,
        file: StaticString = #filePath, line: UInt = #line
    ) throws -> SiriAnswer {
        let location = SourceLocation(file: file, line: line)
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let siri = XCUIDevice.shared.siriService
        // Dismiss any prior answer before submitting this request.
        XCUIDevice.shared.press(.home)
        siri.activate(voiceRecognitionText: phrase)
        var observed: [String] = []
        var previous: [String] = []
        let ready = NSPredicate { _, _ in
            previous = observed
            observed = siri.staticTexts.allElementsBoundByIndex
                .filter { $0.exists && !$0.frame.isEmpty }
                .map(\.label).filter { !$0.isEmpty }
            return observed.contains(answer) && observed == previous
        }
        let result = XCTWaiter.wait(
            for: [XCTNSPredicateExpectation(predicate: ready, object: nil)],
            timeout: timeout)
        guard result == .completed else {
            throw SiriTranscript(phrase: phrase, observed: observed)
                .failure(answer, location: location)
        }
        return SiriAnswer(phrase: phrase, observed: observed)
        #else
        throw SiriFailure(
            kind: .setup, phrase: phrase, observed: [],
            message: "Siri automation requires an iOS UI test runner",
            location: location)
        #endif
    }
}
