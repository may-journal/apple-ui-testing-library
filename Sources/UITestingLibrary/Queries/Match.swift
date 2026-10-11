/// What a query found among the elements on screen in one read.
@MainActor
enum Match {
    case one(Node)
    case none
    case many([Node])

    init(_ query: Query, in tree: AccessibilityTree) {
        let found = tree.nodes.filter { $0.isOnScreen && query.matches($0.element) }
        switch found.count {
        case 0: self = .none
        case 1: self = .one(found[0])
        default: self = .many(found)
        }
    }

    var node: Node? {
        if case .one(let node) = self { return node }
        return nil
    }
}
