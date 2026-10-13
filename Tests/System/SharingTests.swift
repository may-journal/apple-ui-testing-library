import UITestingLibrary
import UITestingLibrarySystem
import XCTest

/// Requirement 0008: system sharing, read from the destination's received bytes. Also 0005.6
/// and 0006.4, which a system session proves.
@MainActor
final class SharingTests: XCTestCase {
    private var session: SystemSession!

    override func tearDown() async throws {
        session?.close()
        session = nil
        try await super.tearDown()
    }

    func share(_ mutation: String? = nil) throws -> SharedDelivery {
        session = SystemSession(
            bundleIdentifier: "org.may-journal.ui-testing-library.TestHost", timeout: 10)
        session.launch(arguments: ["--system-sharing"] + (mutation.map { [$0] } ?? []))
        try session.taps(.button("Share Alex"))
        try session.taps(.button("Share card"))
        return try session.receivesShare()
    }

    func test0008_1() throws {
        let delivery = try share()
        XCTAssertEqual(delivery.messages, ["Alex's card"])
        XCTAssertEqual(delivery.images.count, 1)
        XCTAssertGreaterThan(delivery.images[0].count, 100)
        try session.dismissShare()
        _ = try session.sees(.button("Share Alex"))
    }

    func test0008_2() throws {
        let delivery = try share()
        try delivery.check(
            message: "Alex's card", containing: ["Alex", "Taylor"], excluding: ["Morgan"])
    }

    func test0008_3() throws {
        let delivery = try share("--wrong-image")
        XCTAssertEqual(delivery.messages, ["Alex's card"])
        XCTAssertThrowsError(
            try delivery.check(
                message: "Alex's card", containing: ["Taylor"], excluding: ["Morgan"])
        ) {
            XCTAssertTrue(String(describing: $0).contains("Missing: [\"Taylor\"]"))
        }
    }

    func test0008_4() throws {
        let delivery = try share("--wrong-message")
        XCTAssertEqual(delivery.messages, ["Morgan's card"])
        XCTAssertTrue(try delivery.visibleText().joined().contains("Taylor"))
        XCTAssertThrowsError(
            try delivery.check(
                message: "Alex's card", containing: ["Taylor"], excluding: ["Morgan"])
        ) {
            XCTAssertTrue(String(describing: $0).contains("Morgan's card"), String(describing: $0))
        }
    }

    func test0008_5() throws {
        let delivery = try share("--extra-match")
        XCTAssertThrowsError(
            try delivery.check(
                message: "Alex's card", containing: ["Taylor"], excluding: ["Morgan"])
        ) {
            XCTAssertTrue(String(describing: $0).contains("Unexpected: [\"Morgan\"]"))
        }
    }

    func test0005_6() throws {
        session = SystemSession(
            bundleIdentifier: "org.may-journal.ui-testing-library.TestHost", timeout: 1)
        session.launch(arguments: ["--system-sharing"])
        let line: UInt = 123
        XCTAssertThrowsError(
            try session.sees(.button("Absent destination"), file: "DeliveryTests.swift", line: line)
        ) {
            guard let failure = $0 as? Failure else { return XCTFail("Expected Failure") }
            XCTAssertEqual(failure.location.line, line)
            XCTAssertTrue(failure.description.contains("Share Alex"))
        }
    }

    func test0008_7() throws {
        session = SystemSession(
            bundleIdentifier: "org.may-journal.ui-testing-library.TestHost", timeout: 10)
        session.launch(arguments: ["--system-sharing"])
        try session.taps(.button("Share Alex"))
        try session.taps(.button("Share card"))
        try session.dismissShare(.button("Close"))
        _ = try session.sees(.button("Share Alex"))
    }

    func test0008_8() throws {
        session = SystemSession(
            bundleIdentifier: "org.may-journal.ui-testing-library.TestHost", timeout: 10)
        session.launch(arguments: ["--system-sharing", "--scroll-share"])
        try session.scrolls(.down)
        try session.scrolls(.down)
        try session.scrolls(.down)
        try session.taps(.button("Share Alex"))
        _ = try session.sees(.button("Share card"))
    }

    func test0006_4() throws {
        session = SystemSession(
            bundleIdentifier: "org.may-journal.ui-testing-library.TestHost", timeout: 10)
        session.launch(arguments: ["--system-sharing", "--disabled-share"])
        _ = try session.sees(.button("Share Alex"))
        let button = try XCTUnwrap(session.elements().first { $0.label == "Share Alex" })
        XCTAssertFalse(button.isEnabled)
        XCTAssertThrowsError(try session.taps(.button("Share Alex"))) {
            XCTAssertTrue(String(describing: $0).contains("disabled"))
        }
        XCTAssertFalse(session.reads().contains("Share card"))
    }

    func test0008_9() throws {
        let missing = try share("--missing-image")
        XCTAssertTrue(missing.images.isEmpty)
        try checkFailure(missing, containing: "Missing image")
        session.close()
        let malformed = try share("--malformed-image")
        XCTAssertEqual(malformed.images, [Data("broken image".utf8)])
        try checkFailure(malformed, containing: "Cannot read shared image")
    }

    private func checkFailure(_ delivery: SharedDelivery, containing message: String) throws {
        XCTAssertThrowsError(
            try delivery.check(
                message: "Alex's card", containing: ["Taylor"], excluding: [],
                file: "DeliveryTests.swift", line: 123)
        ) {
            guard let failure = $0 as? Failure else {
                return XCTFail("Expected located Failure: \($0)")
            }
            XCTAssertEqual(failure.location.filePath, "DeliveryTests.swift")
            XCTAssertEqual(failure.location.line, 123)
            XCTAssertTrue(failure.description.contains(message), failure.description)
            XCTAssertTrue(failure.description.contains("Alex's card"), failure.description)
        }
    }
}
