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
        let url = makeSearchURL(query: query, page: page)
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.get(from: url, headers: [:])
        } catch {
            throw Error.connectivity
        }
        return try ArtistSearchMapper.map(data, from: response)
    }

    private func makeSearchURL(query: String, page: Int) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/database/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "artist"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30")
        ]
        return components.url!
    }
}
