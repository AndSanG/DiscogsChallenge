import Foundation

public struct Page<T: Sendable>: Sendable {
    public let items: [T]
    public let hasNextPage: Bool

    public init(items: [T], hasNextPage: Bool) {
        self.items = items
        self.hasNextPage = hasNextPage
    }
}
