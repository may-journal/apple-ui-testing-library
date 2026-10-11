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
                return !tree.elements.isEmpty && !tree.onScreen.contains(where: query.matches)
            }
            if gone { return }
            if tree.elements.isEmpty {
                throw failure(
                    "Expected not to see \(query), but the screen read empty",
                    SourceLocation(file: file, line: line))
            }
            throw failure(
                "Expected not to see \(query), and it is still on screen",
                SourceLocation(file: file, line: line))
        }
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
