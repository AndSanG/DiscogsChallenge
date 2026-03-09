import Foundation
import Testing
@testable import DiscogsSearch

@Suite("RemoteArtistSearchLoader")
struct RemoteArtistSearchLoaderTests {

    @Test func init_doesNotRequestData() {
        let (_, spy) = makeSUT()
        #expect(spy.requests.isEmpty)
    }

    @Test func load_requestsDataFromURL() async throws {
        let baseURL = URL(string: "https://api.discogs.com")!
        let (sut, spy) = makeSUT(baseURL: baseURL)
        spy.stub(.success((makeSearchJSON(), makeResponse(statusCode: 200))))

        _ = try await sut.load(query: "Metallica", page: 1)

        #expect(spy.requests.count == 1)
        let url = try #require(spy.requests.first?.url)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.scheme == "https")
        #expect(components?.host == "api.discogs.com")
        #expect(components?.path == "/database/search")
        #expect(components?.queryItems?.contains(URLQueryItem(name: "q", value: "Metallica")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "type", value: "artist")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "page", value: "1")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "per_page", value: "30")) == true)
    }

    // MARK: - Helpers

    private func makeSUT(
        baseURL: URL = URL(string: "https://api.discogs.com")!
    ) -> (RemoteArtistSearchLoader, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteArtistSearchLoader(client: spy, baseURL: baseURL)
        return (sut, spy)
    }
}
