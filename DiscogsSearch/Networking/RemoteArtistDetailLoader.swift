import Foundation

public final class RemoteArtistDetailLoader: ArtistDetailLoader, @unchecked Sendable {
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

    public func load(artistID: Int) async throws -> Artist {
        let url = baseURL.appendingPathComponent("/artists/\(artistID)")
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.get(from: url, headers: [:])
        } catch is CancellationError {
            throw CancellationError()
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch {
            throw Error.connectivity
        }
        return try ArtistDetailMapper.map(data, from: response)
    }
}
