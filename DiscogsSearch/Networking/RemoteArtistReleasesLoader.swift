import Foundation

public final class RemoteArtistReleasesLoader: ArtistReleasesLoader, @unchecked Sendable {
    public enum Error: Swift.Error, LocalizedError {
        case connectivity
        case invalidData

        public var errorDescription: String? {
            switch self {
            case .connectivity: return "Check your internet connection and try again."
            case .invalidData: return "Something went wrong. Please try again."
            }
        }
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
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw Error.connectivity
        }
        return try ArtistReleasesMapper.map(data, from: response)
    }

    private func makeReleasesURL(artistID: Int, page: Int) -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid base URL: \(baseURL)")
        }
        components.path = "/artists/\(artistID)/releases"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "sort", value: "year"),
            URLQueryItem(name: "sort_order", value: "desc")
        ]
        guard let url = components.url else {
            preconditionFailure("Unable to construct releases URL from components")
        }
        return url
    }
}
