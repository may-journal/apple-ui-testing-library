import CoreGraphics

/// The screen a root view is laid out for, whatever the test runs on.
public struct ScreenSize: Sendable, Equatable {
    /// The window's size in points.
    public let points: CGSize
    /// Whether the horizontal size class is regular, as on an iPad.
    public let isRegularWidth: Bool

    public init(points: CGSize, isRegularWidth: Bool) {
        self.points = points
        self.isRegularWidth = isRegularWidth
    }

    /// A phone's screen, portrait.
    public static let phone = ScreenSize(
        points: CGSize(width: 402, height: 874), isRegularWidth: false)
    /// An iPad's screen, portrait.
    public static let pad = ScreenSize(
        points: CGSize(width: 1024, height: 1366), isRegularWidth: true)
}
