#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

/// Drags in AppKit without the window server: the press and moves go to the test's window,
/// the hosting view keeps the drag SwiftUI begins, and the view under the target hears it
/// through its dragging destination methods (ADR 0011).
extension Backend {
    /// Drags the element onto `target`, as a press, a move and a release do. The press and
    /// moves go to the window, so SwiftUI begins its drag; the window keeps the drag in
    /// process, and the view under the target hears it arrive and drop through its dragging
    /// destination methods, as the window server would call them (ADR 0011).
    static func drag(_ node: Node, onto target: Node, in window: HostWindow) async -> DragOutcome {
        let front = frontWindow(of: window.window)
        guard let start = middle(of: node), let end = middle(of: target) else {
            return .noDrag
        }
        kept = nil
        send(mouse(.leftMouseDown, at: start, clicks: 1, in: front), to: front)
        let steps = 10
        for step in 1...steps where kept == nil {
            let progress = CGFloat(step) / CGFloat(steps)
            let point = CGPoint(
                x: start.x + (end.x - start.x) * progress, y: start.y + (end.y - start.y) * progress
            )
            send(mouse(.leftMouseDragged, at: point, clicks: 1, in: front), to: front)
            await Task.yield()
        }
        defer {
            send(mouse(.leftMouseUp, at: end, clicks: 1, in: front), to: front)
            kept = nil
        }
        guard let drag = kept else { return .noDrag }
        guard let destination = destination(at: end, in: front) else { return .refused }
        let board = NSPasteboard(name: NSPasteboard.Name("org.may-journal.ui-testing-library.drag"))
        board.clearContents()
        board.writeObjects(drag.items.compactMap { $0.item as? NSPasteboardWriting })
        defer { board.releaseGlobally() }
        let info = DraggingInfo(window: front, location: end, board: board, source: drag.source)
        guard !destination.draggingEntered(info).isEmpty,
            !destination.draggingUpdated(info).isEmpty, destination.prepareForDragOperation(info)
        else {
            destination.draggingExited(info)
            return .refused
        }
        let dropped = destination.performDragOperation(info)
        destination.concludeDragOperation(info)
        return dropped ? .dropped : .refused
    }

    /// Whether the element can begin a drag; AppKit answers only once the press moves.
    static func offersDrag(from node: Node, onto target: Node, in window: HostWindow) -> Bool {
        true
    }

    /// Keeps the drag a hosting view began, in place of the window server's session.
    static func keepDrag(_ items: [NSDraggingItem], from source: any NSDraggingSource) {
        kept = (items, source)
    }

    private static var kept: (items: [NSDraggingItem], source: any NSDraggingSource)?

    /// The deepest view drawn at `point` that takes drops.
    private static func destination(at point: CGPoint, in window: NSWindow) -> NSView? {
        guard let root = window.contentView else { return nil }
        func deepest(_ view: NSView) -> NSView? {
            for child in view.subviews.reversed() where !child.isHidden {
                if let found = deepest(child) { return found }
            }
            let frame = view.convert(view.bounds, to: nil)
            return frame.contains(point) && !view.registeredDraggedTypes.isEmpty ? view : nil
        }
        return deepest(root)
    }

    /// Forgets a drag kept for a screen that closed.
    static func forgetDrag() {
        kept = nil
    }
}

/// What a dragging destination reads about a drag that never left the process: where it is,
/// what it carries on a pasteboard of its own, and that it may copy or move.
private final class DraggingInfo: NSObject, NSDraggingInfo {
    private let window: NSWindow
    private let location: CGPoint
    private let board: NSPasteboard
    private let source: any NSDraggingSource

    init(window: NSWindow, location: CGPoint, board: NSPasteboard, source: any NSDraggingSource) {
        self.window = window
        self.location = location
        self.board = board
        self.source = source
    }

    var draggingDestinationWindow: NSWindow? { window }
    var draggingSourceOperationMask: NSDragOperation { [.copy, .move, .generic] }
    var draggingLocation: NSPoint { location }
    var draggedImageLocation: NSPoint { location }
    var draggedImage: NSImage? { nil }
    var draggingPasteboard: NSPasteboard { board }
    var draggingSource: Any? { source }
    var draggingSequenceNumber: Int { 1 }
    var draggingFormation: NSDraggingFormation = .none
    var animatesToDestination = false
    var numberOfValidItemsForDrop = 1
    var springLoadingHighlight: NSSpringLoadingHighlight { .none }

    func slideDraggedImage(to screenPoint: NSPoint) {}
    func resetSpringLoading() {}

    func enumerateDraggingItems(
        options enumOpts: NSDraggingItemEnumerationOptions = [], for view: NSView?,
        classes classArray: [AnyClass], searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [:],
        using block: (NSDraggingItem, Int, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        var stop: ObjCBool = false
        let objects = board.readObjects(forClasses: classArray, options: searchOptions) ?? []
        for (index, object) in objects.enumerated() {
            guard let writer = object as? NSPasteboardWriting else { continue }
            block(NSDraggingItem(pasteboardWriter: writer), index, &stop)
            if stop.boolValue { return }
        }
    }
}
#endif
