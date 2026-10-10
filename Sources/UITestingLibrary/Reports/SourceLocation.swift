/// Where in a test a look or act was written, so a failure points there (requirement 0005.5).
public struct SourceLocation: Sendable, Equatable, CustomStringConvertible {
    public let filePath: String
    public let line: UInt

    public init(file: StaticString, line: UInt) {
        filePath = "\(file)"
        self.line = line
    }

    public var description: String {
        "\(filePath.split(separator: "/").last ?? ""):\(line)"
    }
}
