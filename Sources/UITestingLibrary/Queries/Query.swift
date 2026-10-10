/// How a test names an element, in the priority a person finds it (ADR 0002).
public enum Query: Sendable, Equatable, CustomStringConvertible {
    /// A role and its exact label. Comes first.
    case role(Role, String)
    /// What VoiceOver says: the label, the value, or both. Comes next.
    case text(String)
    /// An accessibility identifier. The last resort.
    case identifier(String)

    /// A button with this exact label.
    public static func button(_ label: String) -> Query { .role(.button, label) }

    /// Whether the element is what this query names.
    public func matches(_ element: Element) -> Bool {
        switch self {
        case .role(let role, let label):
            return element.has(role) && element.label == label
        case .text(let text):
            return [element.label, element.value, element.spoken].contains(text)
        case .identifier(let identifier):
            return element.identifier == identifier
        }
    }

    public var description: String {
        switch self {
        case .role(let role, let label): return "\(role.rawValue) \"\(label)\""
        case .text(let text): return "text \"\(text)\""
        case .identifier(let identifier): return "identifier \"\(identifier)\""
        }
    }
}
