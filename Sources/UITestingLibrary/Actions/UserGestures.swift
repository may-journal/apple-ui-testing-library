import CoreGraphics

/// Gestures beyond a tap, named as user-event's `dblClick`, `hover` and `unhover` are, and
/// as a person holds, swipes, drags, adjusts and pinches. Each finds its element, acts through the
/// platform's own entry point, in process, and waits for the screen to settle after
/// (ADR 0011).
extension User {
    /// Double-taps the element `query` finds, as user-event's `dblClick(element)` does: one
    /// double tap, never two taps. It needs a pointer, so on iOS it runs where the app runs
    /// on a Mac.
    public func doubleTaps(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.doubleTaps) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "double-tap", location)
            guard await Backend.doubleTap(node, in: screen.window) else {
                throw failure(
                    "Double-tapping \(query) needs a pointer, which only a Mac sends in "
                        + "process; run the iOS app on a Mac", location)
            }
            _ = await wait.settle(screen)
        }
    }

    /// Presses and holds the element `query` finds, which opens its context menu: while it
    /// is open, a read holds only the menu's items, as for a tapped menu (0003.7).
    public func longPresses(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.longPresses) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "hold", location)
            // A view may add its context menu interaction a moment after it first draws.
            guard await wait.until({ Backend.longPress(node, in: screen.window) }) else {
                throw failure("Holding \(query) opened no menu", location)
            }
            _ = await wait.settle(screen)
        }
    }

    /// Swipes the element `query` finds. A list row shows its swipe actions: left shows the
    /// trailing ones, right the leading ones. Any other element is flicked 100 points left
    /// or right, as `drags(_:by:speed:)` flicks it.
    public func swipes(
        _ direction: SwipeDirection, _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.swipes) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "swipe", location)
            guard Backend.isListRow(node, in: screen.window) else {
                let offset = CGVector(dx: direction == .left ? -100 : 100, dy: 0)
                try await drag(node, query, by: offset, .flick, location)
                return
            }
            guard Backend.swipe(direction, node, in: screen.window) else {
                throw failure(
                    "Swiping \(query) \(direction) showed no actions: it is not a list row with "
                        + "swipe actions, or this platform shows them only for a trackpad's "
                        + "touches (ADR 0011)", location)
            }
            _ = await wait.settle(screen)
        }
    }

    /// Drags the element `query` finds onto the one `target` finds, as a press, a move and a
    /// release do. The drag never leaves the process.
    public func drags(
        _ query: Query, to target: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.drags) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "drag", location)
            let onto = try await drawn(target, "drop onto", location)
            // A view may add its drag and drop interactions a moment after it first draws.
            _ = await wait.until { Backend.offersDrag(from: node, onto: onto, in: screen.window) }
            switch await Backend.drag(node, onto: onto, in: screen.window) {
            case .noDrag: throw failure("Nothing drags from \(query)", location)
            case .refused: throw failure("\(target) takes nothing dragged from \(query)", location)
            case .dropped: break
            }
            _ = await wait.settle(screen)
        }
    }

    /// Steps the slider or stepper `query` finds up or down by one, as VoiceOver's swipe up
    /// and down does, and waits for its value to change.
    public func adjusts(
        _ direction: AdjustDirection, _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.adjusts) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "adjust", location)
            guard node.element.isEnabled else {
                throw failure("Cannot adjust \(query): the control is disabled", location)
            }
            let before = node.element.value
            guard Backend.adjust(direction, node) else {
                throw failure("Cannot adjust \(query): it is not a slider or stepper", location)
            }
            let changed = await wait.until {
                Match(query, in: AccessibilityTree.current(screen)).node?.element.value != before
            }
            guard changed else {
                throw failure(
                    "Adjusting \(query) \(direction) left its value \(before ?? "empty")", location)
            }
            _ = await wait.settle(screen)
        }
    }

    /// Pinches the element `query` finds in or out, as two fingers on a trackpad do, which its
    /// magnify gesture hears. It needs a trackpad's events, so on iOS it runs where the app
    /// runs on a Mac.
    public func pinches(
        _ direction: PinchDirection, _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.pinches) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "pinch", location)
            _ = await wait.until { Backend.showsForPinch(screen.window) }
            guard await Backend.pinch(direction, node, in: screen.window) else {
                throw failure(
                    "Pinching \(query) needs a trackpad's events, which only a Mac sends in "
                        + "process; run the iOS app on a Mac", location)
            }
            _ = await wait.settle(screen)
        }
    }

    /// Moves the pointer over the element `query` finds, as user-event's `hover(element)`
    /// does. It needs a pointer, so on iOS it runs where the app runs on a Mac.
    public func hovers(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.hovers) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "hover over", location)
            guard Backend.hover(node, in: screen.window) else {
                throw failure(
                    "Hovering over \(query) needs a pointer, which only a Mac sends in process; "
                        + "run the iOS app on a Mac", location)
            }
            _ = await wait.settle(screen)
        }
    }

    /// Moves the pointer off the element `query` finds, as user-event's `unhover(element)`
    /// does, after a hover.
    public func unhovers(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.unhovers) {
            let location = SourceLocation(file: file, line: line)
            let node = try await drawn(query, "unhover", location)
            guard Backend.unhover(node, in: screen.window) else {
                throw failure("Cannot unhover \(query): the pointer is not over it", location)
            }
            _ = await wait.settle(screen)
        }
    }

    /// The one element `query` finds on screen, waiting for it, failing with `verb` in the
    /// message.
    func drawn(_ query: Query, _ verb: String, _ location: SourceLocation) async throws
        -> Node
    {
        guard let node = await find(query) else {
            throw failure("Expected to \(verb) \(query), and \(found(query))", location)
        }
        return node
    }
}
