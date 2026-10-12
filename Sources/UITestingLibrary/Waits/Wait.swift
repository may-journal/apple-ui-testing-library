import CoreFoundation
import Foundation

/// Polls a condition until it holds or the deadline passes (ADR 0003).
public struct Wait: Sendable, Equatable {
    /// How long a look or act may take before it fails with the screen report.
    public let deadline: Duration
    /// How long the tree rests between reads.
    static let pause = Duration.milliseconds(50)

    public init(deadline: Duration = .seconds(5)) {
        self.deadline = deadline
    }

    /// Polls `condition` until it holds or the deadline passes; whether it held.
    @MainActor
    func until(_ condition: @MainActor () -> Bool) async -> Bool {
        let end = ContinuousClock.now + deadline
        while ContinuousClock.now < end {
            if condition() { return true }
            try? await Task.sleep(for: Self.pause)
        }
        return condition()
    }

    /// Lets the main run loop finish what the act queued, then reads the screen once
    /// (ADR 0003). The run loop goes idle twice: once after the act's own work, and once
    /// after the redraw that work queued.
    @MainActor
    func settle(_ screen: Screen) async -> AccessibilityTree {
        await Timing.measure(.settle) {
            _ = await until { !Backend.isMenuClosing }
            await Idle.next()
            await Idle.next()
            return AccessibilityTree.read(screen)
        }
    }
}

/// One wait for the main run loop to run out of work and get ready to sleep.
@MainActor
final class Idle {
    private var done: CheckedContinuation<Void, Never>?
    private var observer: CFRunLoopObserver?
    private var timer: Timer?

    /// Suspends until the main run loop is about to sleep, after every observer that draws,
    /// or until a pause passes, if the run loop never rests.
    static func next() async {
        let idle = Idle()
        await withCheckedContinuation { done in
            idle.done = done
            idle.observer = CFRunLoopObserverCreateWithHandler(
                nil, CFRunLoopActivity.beforeWaiting.rawValue, false, CFIndex.max
            ) { _, _ in MainActor.assumeIsolated { idle.finish() } }
            CFRunLoopAddObserver(CFRunLoopGetMain(), idle.observer, .commonModes)
            idle.timer = Timer.scheduledTimer(
                withTimeInterval: Wait.pause / .seconds(1), repeats: false
            ) { _ in
                MainActor.assumeIsolated { idle.finish() }
            }
        }
    }

    private func finish() {
        CFRunLoopObserverInvalidate(observer)
        timer?.invalidate()
        done?.resume()
        done = nil
    }
}
