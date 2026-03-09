import Foundation

public protocol ArtistSearchLoader: Sendable {
    func load(query: String, page: Int) async throws -> Page<ArtistSearchResult>
}
