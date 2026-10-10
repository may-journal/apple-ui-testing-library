import Foundation

/// The process-wide switch that makes SwiftUI build its accessibility tree, as it does only
/// while an assistive technology asks (ADR 0004).
public enum Automation: Sendable, Equatable {
    case notTried
    case turnedOn
    case symbolMissing

    /// What happened the one time this process turned automation on.
    @MainActor public private(set) static var state = Automation.notTried

    /// Turns automation on once per process; later calls do nothing.
    @MainActor
    static func turnOn() {
        guard state == .notTried else { return }
        state = Backend.turnOnAutomation() ? .turnedOn : .symbolMissing
    }
}

#if canImport(UIKit)
extension Backend {
    /// Calls `_AXSSetAutomationEnabled(1)` through `dlsym`, as Xcode's UI tests do; whether
    /// the symbol was there.
    static func turnOnAutomation() -> Bool {
        guard let library = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW),
            let symbol = dlsym(library, "_AXSSetAutomationEnabled")
        else { return false }
        typealias SetEnabled = @convention(c) (Int32) -> Void
        unsafeBitCast(symbol, to: SetEnabled.self)(1)
        return true
    }
}
#else
import AppKit

extension Backend {
    /// Sets `AXEnhancedUserInterface` on the app, as VoiceOver does when it starts reading
    /// an app; whether the app answers to it.
    static func turnOnAutomation() -> Bool {
        guard NSApp.responds(to: NSSelectorFromString("setAccessibilityEnhancedUserInterface:"))
        else { return false }
        NSApp.setValue(true, forKey: "accessibilityEnhancedUserInterface")
        return true
    }
}
#endif
