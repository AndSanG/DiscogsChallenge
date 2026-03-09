import Foundation
import Testing
@testable import DiscogsSearch

@Suite("RemoteArtistReleasesLoader")
struct RemoteArtistReleasesLoaderTests {

    @Test func init_doesNotRequestData() {
        let (_, spy) = makeSUT()
        #expect(spy.requests.isEmpty)
    }


    @Test func load_requestsCorrectURL() async throws {
        let baseURL = URL(string: "https://api.discogs.com")!
        let (sut, spy) = makeSUT(baseURL: baseURL)
        spy.stub(.success((makeReleasesJSON(), makeResponse(statusCode: 200))))

        _ = try await sut.load(artistID: 456, page: 2)

        #expect(spy.requests.count == 1)
        let url = try #require(spy.requests.first?.url)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.path == "/artists/456/releases")
        #expect(components?.queryItems?.contains(URLQueryItem(name: "page", value: "2")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "per_page", value: "30")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "sort", value: "year")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "sort_order", value: "desc")) == true)
    }

    // MARK: - Helpers

    private func makeSUT(
        baseURL: URL = URL(string: "https://api.discogs.com")!
    ) -> (RemoteArtistReleasesLoader, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteArtistReleasesLoader(client: spy, baseURL: baseURL)
        return (sut, spy)
    }

    private func makeReleasesJSON(
        _ items: [[String: Any]] = [],
        page: Int = 1,
        pages: Int = 1
    ) -> Data {
        let json: [String: Any] = [
            "releases": items,
            "pagination": ["page": page, "pages": pages, "per_page": 30, "items": items.count]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func makeReleaseItem(
        id: Int, title: String, year: Int,
        genres: [String], labels: [String],
        thumb: String, type: String
    ) -> [String: Any] {
        [
            "id": id,
            "title": title,
            "year": year,
            "genres": genres,
            "labels": labels.map { ["name": $0] },
            "thumb": thumb,
            "type": type
        ]
    }
}
