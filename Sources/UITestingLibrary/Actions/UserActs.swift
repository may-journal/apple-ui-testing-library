/// Acts a person does on screen, each through a VoiceOver entry point (ADR 0001). Each act
/// finds its element first and waits for the screen to settle after.
extension User {
    /// Taps the one actionable element `query` finds.
    public func taps(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        let node = try await actionable(query, SourceLocation(file: file, line: line))
        guard Backend.activate(node, in: screen.window) else {
            throw failure(
                "Tapping \(query) did nothing: a system menu accessibility cannot open "
                    + "needs a touch tool, as the README shows",
                SourceLocation(file: file, line: line))
        }
        _ = await wait.settle(screen)
    }

    /// Chooses the custom action named `action` on the element `query` finds, as a hold does.
    public func chooses(
        _ action: String, on query: Query,
        file: StaticString = #filePath, line: UInt = #line
    )
        async throws
    {
        guard let node = await find(query) else {
            throw failure(
                "Expected to hold \(query), and nothing on screen matches",
                SourceLocation(file: file, line: line))
        }
        let offered = node.element.actions
        guard offered.contains(action), Backend.perform(action, on: node) else {
            throw failure(
                "\(query) offers \(offered), not \"\(action)\"",
                SourceLocation(file: file, line: line))
        }
        _ = await wait.settle(screen)
    }

    /// Types `text` on the keyboard, into the field being edited.
    public func types(
        _ text: String,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        let typed = await wait.until { Backend.type(text, in: screen.window) }
        guard typed else {
            throw failure("No field is being edited", SourceLocation(file: file, line: line))
        }
        _ = await wait.settle(screen)
    }

    /// Scrolls the page in front by most of a screen, as a three-finger swipe does.
    public func scrolls(
        _ direction: ScrollDirection,
        file: StaticString = #filePath, line: UInt = #line
    )
        async throws
    {
        let scrolled = await wait.until {
            Backend.scroll(
                direction, nodes: AccessibilityTree.read(screen).nodes, in: screen.window)
        }
        guard scrolled else {
            throw failure("Nothing on screen scrolls", SourceLocation(file: file, line: line))
        }
        _ = await wait.settle(screen)
    }

    /// Goes back a screen, as VoiceOver's two-finger scrub does.
    public func goesBack(
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        let went = await wait.until {
            Backend.goBack(from: AccessibilityTree.read(screen).nodes, in: screen.window)
        }
        guard went else {
            throw failure("Nothing on screen went back", SourceLocation(file: file, line: line))
        }
        _ = await wait.settle(screen)
    }

    /// The one actionable element `query` finds, waiting for it.
    private func actionable(_ query: Query, _ location: SourceLocation) async throws -> Node {
        guard let node = await find(query) else {
            throw failure(
                "Nothing tappable has the label \(query): nothing on screen matches",
                location)
        }
        guard node.element.isActionable else {
            throw failure(
                "Nothing tappable has the label \(query): \(node.element) is not actionable",
                location)
        }
        return node
    }
}
