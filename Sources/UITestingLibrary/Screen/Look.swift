import SwiftUI

/// How a root is drawn besides its size: the text size and the appearance a person chose.
/// Each overrides the system's for that root only; nil keeps the system's.
public struct Look: Sendable, Equatable {
    /// The text size, as a person sets it in Display & Text Size.
    public let textSize: DynamicTypeSize?
    /// Light or dark.
    public let appearance: ColorScheme?

    public init(textSize: DynamicTypeSize? = nil, appearance: ColorScheme? = nil) {
        self.textSize = textSize
        self.appearance = appearance
    }

    /// The system's text size and appearance.
    public static let system = Look()
}
