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
        let url = makeReleasesURL(artistID: artistID, page: page)
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.get(from: url, headers: [:])
        } catch {
            throw Error.connectivity
        }
        return try ArtistReleasesMapper.map(data, from: response)
    }

    private func makeReleasesURL(artistID: Int, page: Int) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/artists/\(artistID)/releases"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "sort", value: "year"),
            URLQueryItem(name: "sort_order", value: "desc")
        ]
        return components.url!
    }
}
