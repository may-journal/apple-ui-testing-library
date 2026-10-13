import UITestingLibrary
import XCTest

/// A separate UI-test process for the app and system UI. Hosted tests keep using Screen.
@MainActor
public final class SystemSession {
    public let application: XCUIApplication
    public let timeout: TimeInterval

    public init(bundleIdentifier: String, timeout: TimeInterval = 5) {
        precondition(timeout.isFinite && timeout > 0)
        application = XCUIApplication(bundleIdentifier: bundleIdentifier)
        self.timeout = timeout
    }

    public func launch(arguments: [String] = []) {
        application.launchArguments = arguments
        application.launch()
    }

    /// Stops only this session's app. The caller owns simulator shutdown.
    public func close() { application.terminate() }

    public func sees(
        _ query: Query, file: StaticString = #filePath, line: UInt = #line
    ) throws -> XCUIElement {
        try finds(candidates(for: query), description: "\(query)", file: file, line: line)
    }

    func finds(
        _ candidates: XCUIElementQuery, description: String, file: StaticString, line: UInt
    ) throws -> XCUIElement {
        var matches = candidates.allElementsBoundByIndex.filter(\.isHittable)
        if matches.count == 1, let match = matches.first { return match }
        let condition = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                matches = candidates.allElementsBoundByIndex.filter(\.isHittable)
                return matches.count == 1
            }, object: nil)
        guard XCTWaiter.wait(for: [condition], timeout: timeout) == .completed,
            let match = matches.first
        else {
            throw failure(
                "Expected one \(description); found \(matches.count)", file: file, line: line)
        }
        return match
    }

    public func taps(_ query: Query, file: StaticString = #filePath, line: UInt = #line) throws {
        let element = try sees(query, file: file, line: line)
        guard element.isEnabled else {
            throw failure("Cannot tap \(query): the control is disabled", file: file, line: line)
        }
        guard element.isHittable else {
            throw failure("Cannot tap \(query)", file: file, line: line)
        }
        element.tap()
    }

    public func reads() -> [String] {
        elements().filter(\.isOnScreen).map(\.spoken).filter { !$0.isEmpty }
    }

    /// Scrolls the one visible list or scroll view, failing on missing or ambiguous containers.
    public func scrolls(
        _ direction: ScrollDirection, file: StaticString = #filePath, line: UInt = #line
    ) throws {
        let containers = [XCUIElement.ElementType.scrollView, .collectionView, .table]
            .flatMap { application.descendants(matching: $0).allElementsBoundByIndex }
            .filter(\.isHittable)
        guard containers.count == 1, let container = containers.first else {
            throw failure(
                "Expected one scroll container; found \(containers.count)", file: file, line: line)
        }
        if direction == .down { container.swipeUp() } else { container.swipeDown() }
    }

    public func failure(_ message: String, file: StaticString, line: UInt) -> Failure {
        let snapshot = elements()
        return Failure(
            message,
            report: ScreenReport(
                onScreen: snapshot.filter(\.isOnScreen),
                offScreen: snapshot.filter { !$0.isOnScreen }),
            location: SourceLocation(file: file, line: line))
    }

    public func elements() -> [Element] {
        application.descendants(matching: .any).allElementsBoundByIndex
            .filter { $0.exists && !$0.frame.isEmpty }.map(read)
    }

    private func candidates(for query: Query) -> XCUIElementQuery {
        switch query {
        case .role(let role, let label):
            return roleCandidates(role, label: label)
        case .text(let text):
            return application.descendants(matching: .any).matching(
                NSPredicate(format: "label == %@ OR value == %@", text, text))
        case .identifier(let identifier):
            return application.descendants(matching: .any).matching(
                NSPredicate(format: "identifier == %@", identifier))
        }
    }

    private func roleCandidates(_ role: Role, label: String) -> XCUIElementQuery {
        let predicate: NSPredicate
        if role == .selected {
            predicate = NSPredicate(format: "selected == true AND label == %@", label)
        } else {
            let types = Self.roles.filter { $0.value == role }.map(\.key.rawValue)
            predicate = NSPredicate(format: "elementType IN %@ AND label == %@", types, label)
        }
        return application.descendants(matching: .any).matching(predicate)
    }

    private func read(_ item: XCUIElement) -> Element {
        let role = Self.roles[item.elementType]
        var roles: Set<Role> = role.map { [$0] } ?? []
        if item.isSelected { roles.insert(.selected) }
        return Element(
            label: item.label, value: item.value as? String,
            identifier: item.identifier, roles: roles, frame: item.frame,
            isOnScreen: item.isHittable, isEnabled: item.isEnabled)
    }

    private static let roles: [XCUIElement.ElementType: Role] = [
        .button: .button, .link: .link, .image: .image, .staticText: .text,
        .textField: .textField, .secureTextField: .textField, .textView: .textField,
        .searchField: .searchField, .slider: .adjustable, .switch: .toggle,
    ]
}
