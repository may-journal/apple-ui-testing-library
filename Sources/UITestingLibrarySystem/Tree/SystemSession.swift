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
        var matches: [XCUIElement] = []
        let condition = XCTNSPredicateExpectation(
            predicate: NSPredicate { [self] _, _ in
                matches = application.descendants(matching: .any).allElementsBoundByIndex.filter {
                    $0.exists && !$0.frame.isEmpty && query.matches(read($0))
                }
                return matches.count == 1
            }, object: nil)
        guard XCTWaiter.wait(for: [condition], timeout: timeout) == .completed,
            let match = matches.first
        else {
            throw failure("Expected one \(query); found \(matches.count)", file: file, line: line)
        }
        return match
    }

    public func taps(_ query: Query, file: StaticString = #filePath, line: UInt = #line) throws {
        let element = try sees(query, file: file, line: line)
        guard element.isHittable else {
            throw failure("Cannot tap \(query)", file: file, line: line)
        }
        element.tap()
    }

    public func reads() -> [String] { elements().map(\.spoken).filter { !$0.isEmpty } }

    public func failure(_ message: String, file: StaticString, line: UInt) -> Failure {
        Failure(
            message, report: ScreenReport(onScreen: elements(), offScreen: []),
            location: SourceLocation(file: file, line: line))
    }

    private func elements() -> [Element] {
        application.descendants(matching: .any).allElementsBoundByIndex
            .filter { $0.exists && !$0.frame.isEmpty }.map(read)
    }

    private func read(_ item: XCUIElement) -> Element {
        let role = Self.roles[item.elementType]
        var roles: Set<Role> = role.map { [$0] } ?? []
        if item.isSelected { roles.insert(.selected) }
        return Element(
            label: item.label, value: item.value as? String,
            identifier: item.identifier, roles: roles, frame: item.frame)
    }

    private static let roles: [XCUIElement.ElementType: Role] = [
        .button: .button, .link: .link, .image: .image, .staticText: .text,
        .textField: .textField, .secureTextField: .textField, .textView: .textField,
        .searchField: .searchField, .slider: .adjustable, .switch: .toggle,
    ]
}
