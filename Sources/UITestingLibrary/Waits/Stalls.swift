import Foundation

/// Times how long the main thread goes without answering, as a frozen screen feels to a
/// person. A timer on the main run loop asks to fire every few milliseconds; a fire that
/// comes late means the main thread was busy for the gap.
@MainActor
final class Stalls {
    /// How often the timer asks to fire.
    static let interval = Duration.milliseconds(10)
    private var timer: Timer?
    private var last = ContinuousClock.now
    private var longestGap = Duration.zero

    /// Starts timing the main thread now.
    static func watch() -> Stalls {
        let stalls = Stalls()
        stalls.timer = Timer(timeInterval: interval / .seconds(1), repeats: true) { _ in
            MainActor.assumeIsolated { stalls.tick() }
        }
        stalls.timer.map { RunLoop.main.add($0, forMode: .common) }
        return stalls
    }

    /// Stops timing. The longest the main thread went without answering.
    func longest() -> Duration {
        tick()
        timer?.invalidate()
        timer = nil
        return longestGap
    }

    private func tick() {
        let now = ContinuousClock.now
        longestGap = max(longestGap, now - last)
        last = now
    }
}
