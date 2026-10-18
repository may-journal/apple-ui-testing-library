/// Keys and the clipboard, named as user-event's `keyboard`, `tab`, `clear`, `copy`, `cut`
/// and `paste` are. Each acts in the field being edited, through its own key commands and
/// edit actions, and waits for the screen to settle after; a key's shortcut answers with or
/// without one (ADR 0010, ADR 0011).
extension User {
    /// Presses `key` with `modifiers` held, as user-event's `keyboard("{Meta>}3{/Meta}")`
    /// does: `presses("3", with: [.command])`. A shortcut or app command that answers the
    /// key runs first, with or without a field being edited. Otherwise the field being
    /// edited hears it: a character types, Enter submits a one-line field, End and Home move
    /// to its ends, and Tab moves to the next field.
    public func presses(
        _ key: Key, with modifiers: Set<Modifier> = [],
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.presses) {
            let pressed = await wait.until {
                Backend.press(
                    key, with: modifiers, nodes: AccessibilityTree.current(screen).nodes,
                    in: screen.window)
            }
            guard pressed else {
                throw failure(
                    "No field is being edited, and no shortcut answers \(key)",
                    SourceLocation(file: file, line: line))
            }
            _ = await wait.settle(screen)
        }
    }

    /// Moves focus from the field being edited to the next field, or with `backward` to the
    /// one before, as user-event's `tab()` and `tab({shift: true})` do.
    public func tabs(
        backward: Bool = false,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.tabs) {
            try await editsField(SourceLocation(file: file, line: line)) {
                Backend.press(
                    .tab, with: backward ? [.shift] : [],
                    nodes: AccessibilityTree.current(screen).nodes, in: screen.window)
            }
        }
    }

    /// Edits the field `query` finds and deletes every character in it, as user-event's
    /// `clear(element)` does.
    public func clears(
        _ query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.clears) {
            let location = SourceLocation(file: file, line: line)
            try await startsEditing(query, "clear", location)
            try await editsField(location) { Backend.clearField(in: screen.window) }
        }
    }

    /// Edits the field `query` finds and selects all it holds, as Command-A does.
    public func selectsAll(
        in query: Query,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.selectsAll) {
            let location = SourceLocation(file: file, line: line)
            try await startsEditing(query, "select all in", location)
            try await editsField(location) { Backend.edit(.selectAll, in: screen.window) }
        }
    }

    /// Copies the selection in the field being edited, as user-event's `copy()` does. The
    /// clipboard holds it until the screen closes, which puts back what it held before.
    public func copies(
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.copies) {
            try await editsField(SourceLocation(file: file, line: line)) {
                Backend.edit(.copy, in: screen.window)
            }
        }
    }

    /// Cuts the selection from the field being edited, as user-event's `cut()` does.
    public func cuts(
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.cuts) {
            try await editsField(SourceLocation(file: file, line: line)) {
                Backend.edit(.cut, in: screen.window)
            }
        }
    }

    /// Pastes into the field being edited, as user-event's `paste()` does: what the clipboard
    /// holds, or `text` put on it first, as `paste(text)` does.
    public func pastes(
        _ text: String? = nil,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        try await Timing.measure(.pastes) {
            if let text { Backend.putOnClipboard(text) }
            try await editsField(SourceLocation(file: file, line: line)) {
                Backend.edit(.paste, in: screen.window)
            }
        }
    }

    /// Finds the field `query` names and makes it the one being edited, as a tap into it
    /// does, failing with `verb` in the message.
    private func startsEditing(_ query: Query, _ verb: String, _ location: SourceLocation)
        async throws
    {
        guard let node = await find(query) else {
            throw failure("Expected to \(verb) \(query), and \(found(query))", location)
        }
        guard node.element.isEnabled else {
            throw failure("Cannot \(verb) \(query): the field is disabled", location)
        }
        guard await wait.until({ Backend.edit(node, in: screen.window) }) else {
            throw failure("Cannot \(verb) \(query): it takes no text", location)
        }
    }
}
