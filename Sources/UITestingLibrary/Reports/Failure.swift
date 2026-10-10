/// A failed look or act: what went wrong, what VoiceOver read then, and the test line that
/// asked. Thrown, so the test fails at once with the report in its message.
public struct Failure: Error, CustomStringConvertible {
    public let message: String
    public let report: ScreenReport
    public let location: SourceLocation

    public init(_ message: String, report: ScreenReport, location: SourceLocation) {
        self.message = message
        self.report = report
        self.location = location
    }

    public var description: String { "\(message) (\(location))\n\(report)" }
}
