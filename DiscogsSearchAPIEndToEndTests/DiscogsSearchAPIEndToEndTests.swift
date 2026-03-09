import Foundation
import Testing
@testable import DiscogsSearch

// MARK: - Metallica is the known fixture artist (Discogs ID 18839).
// Tests require a valid DISCOGS_API_TOKEN environment variable.

@Suite("Discogs API End-to-End")
struct DiscogsSearchAPIEndToEndTests {

    private let client = makeAuthenticatedClient()
    private let baseURL = URL(string: "https://api.discogs.com")!

    @Test func search_deliversNonEmptyResultsForKnownArtist() async throws {
        guard tokenIsSet else { return }
        let sut = RemoteArtistSearchLoader(client: client, baseURL: baseURL)
        let page = try await sut.load(query: "Metallica", page: 1)
        #expect(!page.items.isEmpty)
    }

    @Test func artistDetail_deliversArtistForKnownID() async throws {
        guard tokenIsSet else { return }
        let sut = RemoteArtistDetailLoader(client: client, baseURL: baseURL)
        let artist = try await sut.load(artistID: 18839)
        #expect(artist.id == 18839)
        #expect(artist.name == "Metallica")
    }

    @Test func artistReleases_deliversNonEmptyPageForKnownArtist() async throws {
        guard tokenIsSet else { return }
        let sut = RemoteArtistReleasesLoader(client: client, baseURL: baseURL)
        let page = try await sut.load(artistID: 18839, page: 1)
        #expect(!page.items.isEmpty)
    }
}

// MARK: - Helpers

private var tokenIsSet: Bool {
    ProcessInfo.processInfo.environment["DISCOGS_API_TOKEN"] != nil
}

private func makeAuthenticatedClient() -> any HTTPClient {
    let session = URLSession(configuration: .ephemeral)
    let base = URLSessionHTTPClient(session: session)
    return AuthenticatedHTTPClient(decoratee: base)
}

// MARK: - AuthenticatedHTTPClient

private final class AuthenticatedHTTPClient: HTTPClient, @unchecked Sendable {
    private let decoratee: any HTTPClient

    init(decoratee: any HTTPClient) {
        self.decoratee = decoratee
    }

    func get(from url: URL, headers: [String: String]) async throws -> (Data, HTTPURLResponse) {
        let token = ProcessInfo.processInfo.environment["DISCOGS_API_TOKEN"] ?? ""
        var enriched = headers
        enriched["Authorization"] = "Discogs token=\(token)"
        return try await decoratee.get(from: url, headers: enriched)
    }
}
