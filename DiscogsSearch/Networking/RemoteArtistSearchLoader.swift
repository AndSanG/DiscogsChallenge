import Foundation

public final class RemoteArtistSearchLoader: ArtistSearchLoader, @unchecked Sendable {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private let client: any HTTPClient
    private let baseURL: URL

    public init(client: any HTTPClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    public func load(query: String, page: Int) async throws -> Page<ArtistSearchResult> {
        fatalError("not implemented")
    }
}
