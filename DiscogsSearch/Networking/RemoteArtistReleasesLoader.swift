import Foundation

public final class RemoteArtistReleasesLoader: ArtistReleasesLoader, @unchecked Sendable {
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

    public func load(artistID: Int, page: Int) async throws -> Page<Release> {
        throw Error.connectivity
    }
}
