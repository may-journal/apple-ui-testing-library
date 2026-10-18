/// Acts a person does on screen, each through a VoiceOver entry point (ADR 0001). Each act
/// finds its element first and waits for the screen to settle after.
extension User {
    /// Taps the one actionable element `query` finds.
    public func taps(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.taps) {
            let node = try await actionable(query, SourceLocation(file: file, line: line))
            guard Backend.activate(node, in: screen.window) else {
                throw failure(
                    "Tapping \(query) did nothing. A control that opens system UI needs a touch "
                        + "tool; see the README",
                    SourceLocation(file: file, line: line))
            }
            _ = await wait.settle(screen)
        }
    }

    /// Chooses the custom action named `action` on the element `query` finds, as a hold does.
    public func chooses(
        _ action: String, on query: Query,
        file: StaticString = #filePath, line: UInt = #line
    )
        async throws
    {
        try await Timing.measure(.chooses) {
            guard let node = await find(query) else {
                throw failure(
                    "Expected to hold \(query), and \(found(query))",
                    SourceLocation(file: file, line: line))
            }
            let offered = node.element.actions
            guard offered.contains(action) else {
                throw failure(
                    "\(query) offers \(offered), not \"\(action)\"",
                    SourceLocation(file: file, line: line))
            }
            guard Backend.perform(action, on: node) else {
                throw failure(
                    "Choosing \"\(action)\" on \(query) did nothing",
                    SourceLocation(file: file, line: line))
            }
            _ = await wait.settle(screen)
        }
    }

    /// Types `text` on the keyboard, into the field being edited.
    public func types(
        _ text: String,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.types) {
            try await editsField(SourceLocation(file: file, line: line)) {
                Backend.type(text, in: screen.window)
            }
        }
    }

    /// Scrolls the page in front by most of a screen, as a three-finger swipe does.
    public func scrolls(
        _ direction: ScrollDirection,
        file: StaticString = #filePath, line: UInt = #line
    )
        async throws
    {
        try await Timing.measure(.scrolls) {
            let scrolled = await wait.until {
                Backend.scroll(
                    direction, nodes: AccessibilityTree.current(screen).nodes, in: screen.window)
            }
            guard scrolled else {
                throw failure("Nothing on screen scrolls", SourceLocation(file: file, line: line))
            }
            _ = await wait.settle(screen)
        }
    }

    /// Goes back a screen, as VoiceOver's two-finger scrub does.
    public func goesBack(
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.goesBack) {
            let before = await wait.settle(screen).elements
            let answered = await wait.until {
                Backend.goBack(from: AccessibilityTree.current(screen).nodes, in: screen.window)
            }
            // SwiftUI's Mac nodes answer cancel even with nothing to close, so going back
            // counts only once the settled screen changes.
            var changed = false
            if answered {
                changed = await wait.until {
                    AccessibilityTree.read(screen).elements != before
                }
            }
            guard changed else {
                throw failure("Nothing on screen went back", SourceLocation(file: file, line: line))
            }
            _ = await wait.settle(screen)
        }
    }

    /// Runs `edit` once a field is being edited, then waits for the screen to settle.
    func editsField(_ location: SourceLocation, _ edit: @MainActor () -> Bool)
        async throws
    {
        guard await wait.until(edit) else {
            throw failure("No field is being edited", location)
        }
        _ = await wait.settle(screen)
    }

    /// The one actionable element `query` finds, waiting for it.
    private func actionable(_ query: Query, _ location: SourceLocation) async throws -> Node {
        guard let node = await find(query) else {
            throw failure(
                "Nothing tappable has the label \(query): \(found(query))",
                location)
        }
        guard node.element.isActionable else {
            throw failure(
                "Nothing tappable has the label \(query): \(node.element) is not actionable",
                location)
        }
        guard node.element.isEnabled else {
            throw failure("Cannot tap \(query): the control is disabled", location)
        }
        return node
    }
}
