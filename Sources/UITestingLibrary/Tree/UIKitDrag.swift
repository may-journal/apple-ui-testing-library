#if canImport(UIKit)
import UIKit

/// Drags in UIKit through the drag and drop interactions under the element and the target,
/// as their delegates hear a person's drag, in sessions that never leave the process.
extension Backend {
    /// Drags the element onto `target`, as a person's touch and hold, move and lift do: the
    /// drag interaction under the element gives the items it would lift there, and the drop
    /// interaction under the target hears them arrive and drop, through their delegates, in
    /// sessions that never leave the process.
    static func drag(_ node: Node, onto target: Node, in window: HostWindow) async -> DragOutcome {
        guard let from = node.object as? NSObject, let onto = target.object as? NSObject else {
            return .noDrag
        }
        let start = window.window.convert(from.accessibilityActivationPoint, from: nil)
        let end = window.window.convert(onto.accessibilityActivationPoint, from: nil)
        guard
            let (lift, source) = interaction(UIDragInteraction.self, at: start, in: window.window),
            let liftDelegate = lift.delegate
        else { return .noDrag }
        let dragging = DragSession(at: start, in: window.window)
        let items = liftDelegate.dragInteraction(lift, itemsForBeginning: dragging)
        guard !items.isEmpty else { return .noDrag }
        dragging.items = items
        defer { liftDelegate.dragInteraction?(lift, session: dragging, didEndWith: .copy) }
        _ = source
        return drop(items, at: end, in: window.window)
    }

    /// Drops `items` on the drop interaction under `end`, as its delegate hears a drag arrive,
    /// hover and land; whether it took them.
    private static func drop(_ items: [UIDragItem], at end: CGPoint, in window: UIWindow)
        -> DragOutcome
    {
        guard let (drop, _) = interaction(UIDropInteraction.self, at: end, in: window),
            let dropDelegate = drop.delegate
        else { return .refused }
        let dropping = DropSession(at: end, in: window, items: items)
        guard dropDelegate.dropInteraction?(drop, canHandle: dropping) != false else {
            return .refused
        }
        dropDelegate.dropInteraction?(drop, sessionDidEnter: dropping)
        let proposal = dropDelegate.dropInteraction?(drop, sessionDidUpdate: dropping)
        guard let proposal, proposal.operation == .copy || proposal.operation == .move else {
            dropDelegate.dropInteraction?(drop, sessionDidExit: dropping)
            return .refused
        }
        dropDelegate.dropInteraction?(drop, performDrop: dropping)
        dropDelegate.dropInteraction?(drop, sessionDidEnd: dropping)
        return .dropped
    }

    /// Whether a drag and drop interaction lie under the element and the target, which a
    /// view adds a moment after it first draws.
    static func offersDrag(from node: Node, onto target: Node, in window: HostWindow) -> Bool {
        guard let from = node.object as? NSObject, let onto = target.object as? NSObject else {
            return false
        }
        let start = window.window.convert(from.accessibilityActivationPoint, from: nil)
        let end = window.window.convert(onto.accessibilityActivationPoint, from: nil)
        return interaction(UIDragInteraction.self, at: start, in: window.window) != nil
            && interaction(UIDropInteraction.self, at: end, in: window.window) != nil
    }

    /// The first interaction of `kind` on the view drawn at `point` or a view holding it.
    private static func interaction<Kind: UIInteraction>(
        _ kind: Kind.Type, at point: CGPoint, in window: UIWindow
    ) -> (Kind, UIView)? {
        for view in views(at: point, in: window) {
            if let found = view.interactions.lazy.compactMap({ $0 as? Kind }).first {
                return (found, view)
            }
        }
        return nil
    }
}

/// The parts of a drag a drag and drop delegate reads: where it is, what it carries, and
/// that it stays in this app.
private class Session: NSObject {
    let point: CGPoint
    let window: UIWindow
    @objc var items: [UIDragItem]

    init(at point: CGPoint, in window: UIWindow, items: [UIDragItem] = []) {
        self.point = point
        self.window = window
        self.items = items
    }

    @objc(locationInView:) func location(in view: UIView) -> CGPoint {
        view.convert(point, from: window)
    }
    @objc var allowsMoveOperation: Bool { true }
    @objc var isRestrictedToDraggingApplication: Bool { true }

    @objc func hasItemsConforming(toTypeIdentifiers typeIdentifiers: [String]) -> Bool {
        items.contains { item in
            typeIdentifiers.contains { item.itemProvider.hasItemConformingToTypeIdentifier($0) }
        }
    }

    @objc func canLoadObjects(ofClass aClass: any NSItemProviderReading.Type) -> Bool {
        items.contains { $0.itemProvider.canLoadObject(ofClass: aClass) }
    }
}

private final class DragSession: Session, UIDragSession {
    var localContext: Any?
}

private final class DropSession: Session, UIDropSession {
    var localDragSession: (any UIDragSession)? { nil }
    var progressIndicatorStyle: UIDropSessionProgressIndicatorStyle = .none
    let progress = Progress(totalUnitCount: 1)

    func loadObjects(
        ofClass aClass: any NSItemProviderReading.Type,
        completion: @escaping ([any NSItemProviderReading]) -> Void
    ) -> Progress {
        // Each load answers on a queue of its own; the lock keeps the objects in one place.
        let providers = items.map(\.itemProvider).filter { $0.canLoadObject(ofClass: aClass) }
        let loaded = Loaded()
        let group = DispatchGroup()
        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: aClass) { object, _ in
                loaded.add(object)
                group.leave()
            }
        }
        nonisolated(unsafe) let completion = completion
        group.notify(queue: .main) { completion(loaded.objects) }
        return progress
    }
}

/// The objects a drop loads, gathered from the queues they load on.
private final class Loaded: @unchecked Sendable {
    private let lock = NSLock()
    private var all: [any NSItemProviderReading] = []

    func add(_ object: (any NSItemProviderReading)?) {
        guard let object else { return }
        lock.withLock { all.append(object) }
    }

    var objects: [any NSItemProviderReading] { lock.withLock { all } }
}

#endif
