import CoreGraphics

/// A value read from one accessibility element. Queries and reports share this reading.
public struct Element: Sendable, Equatable, CustomStringConvertible {
    /// What VoiceOver says first.
    public let label: String
    /// What VoiceOver says after the label, if anything.
    public let value: String?
    /// The identifier a test may fall back to.
    public let identifier: String?
    /// The roles its traits give it.
    public let roles: Set<Role>
    /// The names of the custom actions it offers.
    public let actions: [String]
    /// Where it is drawn, in the window's coordinates.
    public let frame: CGRect
    /// Whether its middle is inside the window.
    public let isOnScreen: Bool

    public init(
        label: String, value: String? = nil, identifier: String? = nil, roles: Set<Role> = [],
        actions: [String] = [], frame: CGRect = .zero, isOnScreen: Bool = true
    ) {
        self.label = label
        self.value = value
        self.identifier = identifier
        self.roles = roles
        self.actions = actions
        self.frame = frame
        self.isOnScreen = isOnScreen
    }

    /// What VoiceOver says: the label, then the value.
    public var spoken: String {
        [label, value ?? ""].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    /// Whether VoiceOver gives it this role.
    public func has(_ role: Role) -> Bool { roles.contains(role) }

    /// Whether a tap does something here (ADR 0002).
    public var isActionable: Bool { !roles.isDisjoint(with: Role.actionable) }

    public var description: String {
        let named = roles.map(\.rawValue).sorted().joined(separator: " ")
        return named.isEmpty ? "\"\(spoken)\"" : "\"\(spoken)\" (\(named))"
    }
}

/// One element as read, with the object that acts for it.
@MainActor
struct Node {
    let element: Element
    let object: AnyObject
}
