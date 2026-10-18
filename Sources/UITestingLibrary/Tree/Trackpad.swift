import CoreGraphics
import Foundation
import ObjectiveC

/// A trackpad's magnify event, made as Quartz makes one, for a Mac app and for the iOS app
/// running on a Mac alike. AppKit makes gesture events only from Quartz's, and Quartz names
/// neither a gesture event's fields nor how to place one in a window, so its functions are
/// looked up by name and its fields given by number. Each event is checked to read back as
/// a magnify at its point, so a change fails the pinch, never passes it (ADR 0011).
@MainActor
enum Trackpad {
    /// A magnify event scaling by `amount` at `point` in the window numbered `number`, whose
    /// points count up from its bottom, `height` points below its top. Nil where the app
    /// runs on no Mac, or Quartz no longer makes the event as named here.
    static func magnify(
        by amount: Double, _ phase: GesturePhase, at point: CGPoint,
        inWindow number: Int, height: CGFloat
    ) -> NSObject? {
        guard let quartz = QuartzEvents.shared, let made = quartz.create(nil)?.takeRetainedValue(),
            let events = NSClassFromString("NSEvent") as? NSObject.Type
        else { return nil }
        quartz.setInteger(made, Field.type, gestureType)
        quartz.setInteger(made, Field.gesture, zoomKind)
        quartz.setInteger(made, Field.phase, phase.rawValue)
        quartz.setInteger(made, Field.window, Int64(number))
        quartz.setDouble(made, Field.zoom, amount)
        quartz.setWindowLocation(made, CGPoint(x: point.x, y: height - point.y))
        // Stamped now, as the trackpad stamps it: the iOS app drops a pinch older than the
        // clicks it heard last.
        quartz.setTimestamp(made, UInt64(ProcessInfo.processInfo.systemUptime * 1_000_000_000))
        guard
            let event = events.perform(NSSelectorFromString("eventWithCGEvent:"), with: made)?
                .takeUnretainedValue() as? NSObject,
            event.value(forKey: "type") as? UInt == magnifyType,
            event.value(forKey: "windowNumber") as? Int == number,
            event.value(forKey: "locationInWindow") as? CGPoint == point,
            event.value(forKey: "magnification") as? Double == Double(Float(amount))
        else { return nil }
        return event
    }

    /// Quartz's own field numbers for a gesture event.
    private enum Field {
        static let window: UInt32 = 51
        static let type: UInt32 = 55
        static let gesture: UInt32 = 110
        static let zoom: UInt32 = 113
        static let phase: UInt32 = 132
    }

    /// Quartz's numbers for a gesture event and its trackpad zoom kind, and AppKit's for the
    /// magnify event it reads that as.
    private static let gestureType: Int64 = 29
    private static let zoomKind: Int64 = 8
    private static let magnifyType: UInt = 30
}

/// The Quartz functions that make an event, found by name where the app runs on a Mac.
private struct QuartzEvents {
    typealias Create = @convention(c) (UnsafeRawPointer?) -> Unmanaged<AnyObject>?
    typealias SetInteger = @convention(c) (AnyObject, UInt32, Int64) -> Void
    typealias SetDouble = @convention(c) (AnyObject, UInt32, Double) -> Void
    typealias SetWindowLocation = @convention(c) (AnyObject, CGPoint) -> Void
    typealias SetTimestamp = @convention(c) (AnyObject, UInt64) -> Void

    let create: Create
    let setInteger: SetInteger
    let setDouble: SetDouble
    let setWindowLocation: SetWindowLocation
    let setTimestamp: SetTimestamp

    static let shared: QuartzEvents? = {
        guard let create = function("CGEventCreate", as: Create.self),
            let setInteger = function("CGEventSetIntegerValueField", as: SetInteger.self),
            let setDouble = function("CGEventSetDoubleValueField", as: SetDouble.self),
            let setWindowLocation = function(
                "CGEventSetWindowLocation", as: SetWindowLocation.self),
            let setTimestamp = function("CGEventSetTimestamp", as: SetTimestamp.self)
        else { return nil }
        return QuartzEvents(
            create: create, setInteger: setInteger, setDouble: setDouble,
            setWindowLocation: setWindowLocation, setTimestamp: setTimestamp)
    }()

    private static func function<T>(_ name: String, as type: T.Type) -> T? {
        // dlsym's default handle, -2, searches every image loaded in the process.
        guard let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), name) else {
            return nil
        }
        return unsafeBitCast(symbol, to: type)
    }
}
