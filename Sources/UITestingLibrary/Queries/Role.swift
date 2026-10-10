/// The roles a query names, each mapped to accessibility traits (ADR 0002).
public enum Role: String, Sendable, Hashable, CaseIterable {
    case button
    case link
    case heading
    case image
    case text
    case textField
    case searchField
    case adjustable
    case toggle
    case selected

    /// The roles a tap lands on.
    static let actionable: Set<Role> = [
        .button, .link, .toggle, .adjustable, .textField, .searchField,
    ]
}
