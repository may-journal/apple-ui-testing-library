import CoreGraphics

/// Drags by a distance, as a person's finger or mouse presses, moves and lets go. Each finds
/// its element, sends the pointer's events in process, and waits for the screen to settle
/// after (ADR 0011).
extension User {
    /// Drags the element `query` finds by `offset` and lets go: from its middle, right and
    /// down by the offset's points, as SwiftUI counts them. Its drag gesture hears the speed
    /// too: a slow drag comes to rest before letting go, and a flick lets go while moving
    /// fast. It needs a pointer, so on iOS it runs where the app runs on a Mac.
    public func drags(
        _ query: Query, by offset: CGVector, speed: DragSpeed,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.drags) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "drag", location)
            try await drag(node, query, by: offset, speed, location)
        }
    }

    /// Drags the found element by `offset` at `speed`, then waits for the screen to settle.
    func drag(
        _ node: Node, _ query: Query, by offset: CGVector, _ speed: DragSpeed,
        _ location: SourceLocation
    ) async throws {
        switch await Backend.drag(node, by: offset, speed, in: screen.window) {
        case .noPointer:
            throw failure(
                "Dragging \(query) needs a pointer, which only a Mac sends in process; run the "
                    + "iOS app on a Mac", location)
        case .unheard:
            throw failure(
                "Dragging \(query) found nothing to press: it draws no frame, or the window has "
                    + "no view that hears the pointer", location)
        case .moved: break
        }
        _ = await wait.settle(screen)
    }
}
