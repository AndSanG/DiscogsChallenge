import Foundation

public protocol HTTPClient: Sendable {
    func get(from url: URL, headers: [String: String]) async throws -> (Data, HTTPURLResponse)
}
