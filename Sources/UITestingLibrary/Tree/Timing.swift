import os

/// One timed phase of a test: its signpost name, such as `act`, and a code naming the step,
/// such as `taps`. The log drops the names of a Designed for iPad run, whose binary is gone
/// by then, so each interval's ID starts with the code. `config/timing-phases.json` mirrors
/// these codes for `make requirements-timing`.
struct Phase: Sendable {
    let name: StaticString
    let code: UInt64

    static let render = Phase(name: "render", code: 1)
    static let read = Phase(name: "read", code: 2)
    static let settle = Phase(name: "settle", code: 3)
    static let sees = Phase(name: "look", code: 4)
    static let doesNotSee = Phase(name: "look", code: 5)
    static let reads = Phase(name: "look", code: 6)
    static let taps = Phase(name: "act", code: 7)
    static let chooses = Phase(name: "act", code: 8)
    static let types = Phase(name: "act", code: 9)
    static let scrolls = Phase(name: "act", code: 10)
    static let goesBack = Phase(name: "act", code: 11)
}

/// Signposts that time each phase of a test. Instruments shows them under Points of
/// Interest, and `make requirements-timing` sums them per phase.
@MainActor
enum Timing {
    static let signposter = OSSignposter(
        subsystem: "org.may-journal.ui-testing-library", category: .pointsOfInterest)
    /// How many intervals began; the low half of each interval's ID.
    private static var count: UInt64 = 0

    /// Runs `body` inside a signposted interval for `phase`.
    static func measure<T>(_ phase: Phase, _ body: () throws -> T) rethrows -> T {
        let state = begin(phase)
        defer { signposter.endInterval(phase.name, state) }
        return try body()
    }

    /// The asynchronous form of `measure`, for a phase that waits.
    static func measure<T>(_ phase: Phase, _ body: () async throws -> T) async rethrows -> T {
        let state = begin(phase)
        defer { signposter.endInterval(phase.name, state) }
        return try await body()
    }

    private static func begin(_ phase: Phase) -> OSSignpostIntervalState {
        count += 1
        let id = OSSignpostID(phase.code << 32 | count & 0xFFFF_FFFF)
        return signposter.beginInterval(phase.name, id: id)
    }
}
