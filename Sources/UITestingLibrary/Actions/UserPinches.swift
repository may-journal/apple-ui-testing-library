/// Pinches, as two fingers on a trackpad do, which an element's magnify gesture hears: whole,
/// or held partway so a test reads the screen mid-gesture. Each needs a trackpad's events,
/// so on iOS it runs where the app runs on a Mac (ADR 0011).
extension User {
    /// Pinches the element `query` finds in or out, as two fingers on a trackpad do, which its
    /// magnify gesture hears. The gesture ends at `scale`, as SwiftUI's `MagnifyGesture` reads
    /// its magnification: below 1 for in, above 1 for out. With no scale, a pinch in ends at
    /// half and a pinch out at one and a half.
    public func pinches(
        _ direction: PinchDirection, _ query: Query, to scale: Double? = nil,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.pinches) {
            let location = SourceLocation(file: file, line: line)
            try await pinch(
                direction, query, to: scale ?? direction.scale, holding: false, location)
            _ = await wait.settle(screen)
        }
    }

    /// Starts a pinch on the element `query` finds and stops partway, at `scale`, with the
    /// fingers still down: its magnify gesture has changed but not ended, so the test reads
    /// the screen mid-gesture. The returned pinch's `releases()` ends it. Until then the
    /// window stays where the pinch needs it, and no other pinch may start.
    public func holdsPinch(
        _ direction: PinchDirection, _ query: Query, to scale: Double,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws -> HeldPinch {
        try await Timing.measure(.holdsPinch) {
            let location = SourceLocation(file: file, line: line)
            try await pinch(direction, query, to: scale, holding: true, location)
            _ = await wait.settle(screen)
            return HeldPinch(self, query)
        }
    }

    /// Pinches the found element to `scale`, holding it or ending it, after checking the scale
    /// lies on the direction's side of 1 and no pinch is held.
    private func pinch(
        _ direction: PinchDirection, _ query: Query, to scale: Double, holding: Bool,
        _ location: SourceLocation
    ) async throws {
        guard direction.reaches(scale) else {
            let range = direction == .in ? "between 0 and 1" : "above 1"
            throw failure(
                "Pinching \(query) \(direction) needs a scale \(range), not \(scale)", location)
        }
        guard Backend.heldPinch == nil else {
            throw failure("Cannot pinch \(query) while a pinch is held; release it first", location)
        }
        let node = try await drawn(query, "pinch", location)
        _ = await wait.until { Backend.showsForPinch(screen.window) }
        guard await Backend.pinch(to: scale, node, in: screen.window, holding: holding) else {
            throw failure(
                "Pinching \(query) needs a trackpad's events, which only a Mac sends in "
                    + "process; run the iOS app on a Mac", location)
        }
    }
}

/// A pinch held partway, from `User.holdsPinch(_:_:to:)`: its fingers rest at the scale it
/// reached, and its magnify gesture waits for them to lift.
@MainActor
public final class HeldPinch {
    private let user: User
    private let query: Query
    private var isReleased = false

    init(_ user: User, _ query: Query) {
        self.user = user
        self.query = query
    }

    /// Lifts the fingers: the magnify gesture ends at the held scale, and the screen settles.
    /// A pinch releases once, and only while its screen is open.
    public func releases(file: StaticString = #filePath, line: UInt = #line) async throws {
        try await Timing.measure(.releases) {
            let location = SourceLocation(file: file, line: line)
            guard !isReleased else {
                throw user.failure("The pinch on \(query) is already released", location)
            }
            isReleased = true
            guard await Backend.releasePinch(in: user.screen.window) else {
                throw user.failure(
                    "Releasing the pinch on \(query) failed: its screen closed, or the ended event "
                        + "could not be made", location)
            }
            _ = await user.wait.settle(user.screen)
        }
    }
}
