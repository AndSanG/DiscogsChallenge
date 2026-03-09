import Foundation
import DiscogsSearch

/// Decorates any HTTPClient by injecting a Discogs Authorization header on every request.
final class AuthenticatedHTTPClient: HTTPClient, @unchecked Sendable {
    private let decoratee: any HTTPClient
    private let token: String

    init(decoratee: any HTTPClient, token: String) {
        self.decoratee = decoratee
        self.token = token
    }

    func get(from url: URL, headers: [String: String]) async throws -> (Data, HTTPURLResponse) {
        var enriched = headers
        enriched["Authorization"] = "Discogs token=\(token)"
        return try await decoratee.get(from: url, headers: enriched)
    }
}
