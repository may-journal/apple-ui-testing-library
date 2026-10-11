import UITestingLibrarySystem
import XCTest

/// These tests run in a UI test runner, through Siri rather than the intent handler.
@MainActor
final class SiriTests: XCTestCase {
    private let phrase = "Who did I draw in TestHost"

    func test0007_1() throws {
        let session = SystemSession(
            bundleIdentifier: "org.may-journal.ui-testing-library.TestHost", timeout: 20)
        session.launch()
        defer { session.close() }
        let answer = try session.askSiri(phrase, expecting: "Morgan drew Riley.")
        try answer.excludes("Riley drew Casey")
        try answer.excludes("Casey drew Morgan")
    }

    func test0007_2() throws {
        let session = SystemSession(
            bundleIdentifier: "org.may-journal.ui-testing-library.TestHost", timeout: 20)
        session.launch()
        defer { session.close() }
        // First prove setup works; unavailable Siri cannot satisfy this negative proof.
        _ = try session.askSiri(phrase, expecting: "Morgan drew Riley.")
        session.close()
        session.launch(arguments: ["--wrong-siri-answer"])
        let line = UInt(#line) + 2
        do {
            _ = try session.askSiri(phrase, expecting: "Morgan drew Riley.")
            XCTFail("A wrong app answer passed")
        } catch let failure as SiriFailure {
            XCTAssertEqual(failure.kind, .indeterminate)
            XCTAssertEqual(failure.phrase, phrase)
            XCTAssertTrue(failure.observed.contains("Morgan drew Casey."))
            XCTAssertEqual(failure.location.line, line)
        }
    }
}
