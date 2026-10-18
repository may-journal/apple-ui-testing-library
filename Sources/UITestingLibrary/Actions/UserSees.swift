/// Looks a person takes at the screen, each waiting on a condition up to the deadline.
extension User {
    /// Waits until exactly one element on screen matches `query`, and returns it.
    @discardableResult
    public func sees(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws -> Element {
        try await Timing.measure(.sees) {
            guard let node = await find(query) else {
                throw failure(
                    "Expected to see \(query), and \(found(query))",
                    SourceLocation(file: file, line: line))
            }
            return node.element
        }
    }

    /// Waits until nothing on screen matches `query`. A screen that only ever read empty fails,
    /// since it proved nothing (ADR 0004).
    public func doesNotSee(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.doesNotSee) {
            var tree = AccessibilityTree.current(screen)
            let gone = await wait.until {
                tree = AccessibilityTree.current(screen)
                return !tree.nodes.isEmpty && !tree.onScreen.contains(where: query.matches)
            }
            if gone { return }
            if tree.nodes.isEmpty {
                throw failure(
                    "Expected not to see \(query), but the screen read empty",
                    SourceLocation(file: file, line: line))
            }
            throw failure(
                "Expected not to see \(query), and it is still on screen",
                SourceLocation(file: file, line: line))
        }
    }

    /// Watches the screen for `duration` and fails as soon as anything on screen matches
    /// `query`. `doesNotSee` returns once the match is gone; this watches the whole time
    /// (ADR 0010). A screen that only ever read empty fails, since it proved nothing
    /// (ADR 0004).
    public func neverSees(
        _ query: Query, for duration: Duration,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.neverSees) {
            var shown: Element?
            var readElements = false
            let absent = await Wait(deadline: duration).throughout {
                let tree = AccessibilityTree.current(screen)
                readElements = readElements || !tree.nodes.isEmpty
                shown = tree.onScreen.first(where: query.matches)
                return shown == nil
            }
            if let shown, !absent {
                throw failure(
                    "Expected never to see \(query), and came to see \(shown)",
                    SourceLocation(file: file, line: line))
            }
            if !readElements {
                throw failure(
                    "Expected never to see \(query), but the screen read empty",
                    SourceLocation(file: file, line: line))
            }
        }
    }

    /// Waits until the system share sheet is up over the app. It draws outside the app's
    /// tree, so this finds that it opened, never what it holds; drive it as System UI in the
    /// usage guide shows (ADR 0010).
    public func seesShareSheet(
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.seesShareSheet) {
            guard await wait.until({ Backend.isSharing(over: screen.window) }) else {
                throw failure(
                    "Expected the share sheet, and none came up",
                    SourceLocation(file: file, line: line))
            }
        }
    }

    /// Runs `action` while timing the main thread, and fails if it went `limit` or longer
    /// without answering, naming the longest stall (ADR 0010).
    public func staysResponsive(
        under limit: Duration,
        file: StaticString = #filePath, line: UInt = #line,
        _ action: @MainActor () async throws -> Void
    ) async throws {
        try await Timing.measure(.staysResponsive) {
            let stalls = Stalls.watch()
            do {
                try await action()
            } catch {
                _ = stalls.longest()
                throw error
            }
            let longest = stalls.longest()
            guard longest < limit else {
                throw failure(
                    "Expected the app to stay responsive under \(milliseconds(limit)), and it "
                        + "stalled for \(milliseconds(longest))",
                    SourceLocation(file: file, line: line))
            }
        }
    }

    private func milliseconds(_ duration: Duration) -> String {
        "\(Int((duration / .milliseconds(1)).rounded())) ms"
    }

    /// How many elements match now, in words.
    func found(_ query: Query) -> String {
        switch Match(query, in: AccessibilityTree.read(screen)) {
        case .none: return "nothing on screen matches"
        case .one: return "one matches"
        case .many(let nodes): return "\(nodes.count) elements match"
        }
    }
}
