import Foundation
import Testing
@testable import DiscogsSearch

@Suite("RemoteArtistSearchLoader")
struct RemoteArtistSearchLoaderTests {

    @Test func init_doesNotRequestData() {
        let (_, spy) = makeSUT(); #expect(spy.requests.isEmpty)
    }

    @Test func load_requestsDataFromURL() async throws {
        let baseURL = URL(string: "https://api.discogs.com")!
        let (sut, spy) = makeSUT(baseURL: baseURL)
        spy.stub(.success((makeSearchJSON(), makeResponse(statusCode: 200))))
        _ = try await sut.load(query: "Metallica", page: 1)
        #expect(spy.requests.count == 1)
        let url = try #require(spy.requests.first?.url)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.path == "/database/search")
        #expect(components?.queryItems?.contains(URLQueryItem(name: "q", value: "Metallica")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "per_page", value: "30")) == true)
    }

    @Test func loadTwice_requestsDataFromURLTwice() async throws {
        let (sut, spy) = makeSUT()
        spy.stub(.success((makeSearchJSON(), makeResponse(statusCode: 200))))
        spy.stub(.success((makeSearchJSON(), makeResponse(statusCode: 200))))
        _ = try await sut.load(query: "Metallica", page: 1)
        _ = try await sut.load(query: "Metallica", page: 1)
        #expect(spy.requests.count == 2)
    }

    @Test func load_deliversConnectivityErrorOnClientError() async {
        let (sut, spy) = makeSUT(); spy.stub(.failure(anyError()))
        await #expect(throws: RemoteArtistSearchLoader.Error.connectivity) {
            _ = try await sut.load(query: "Metallica", page: 1)
        }
    }

    @Test("delivers .invalidData on non-200 response", arguments: [199, 201, 300, 400, 500])
    func load_deliversInvalidDataErrorOnNon200Response(statusCode: Int) async {
        let (sut, spy) = makeSUT()
        spy.stub(.success((makeSearchJSON(), makeResponse(statusCode: statusCode))))
        await #expect(throws: RemoteArtistSearchLoader.Error.invalidData) {
            _ = try await sut.load(query: "Metallica", page: 1)
        }
    }

    @Test func load_deliversInvalidDataErrorOn200ResponseWithInvalidJSON() async {
        let (sut, spy) = makeSUT(); spy.stub(.success((anyData(), makeResponse(statusCode: 200))))
        await #expect(throws: RemoteArtistSearchLoader.Error.invalidData) {
            _ = try await sut.load(query: "Metallica", page: 1)
        }
    }


    @Test func load_deliversNoItemsOn200ResponseWithEmptyJSONList() async throws {
        let (sut, spy) = makeSUT()
        spy.stub(.success((makeSearchJSON([]), makeResponse(statusCode: 200))))
        let page = try await sut.load(query: "Metallica", page: 1)
        #expect(page.items.isEmpty)
        #expect(page.hasNextPage == false)
    }


    @Test func load_deliversItemsOn200ResponseWithJSONItems() async throws {
        let (sut, spy) = makeSUT()
        let item1 = makeSearchItem(id: 1, name: "Metallica", thumb: "https://img.discogs.com/1.jpg")
        let item2 = makeSearchItem(id: 2, name: "Megadeth",  thumb: "https://img.discogs.com/2.jpg")
        spy.stub(.success((makeSearchJSON([item1, item2], page: 1, pages: 3), makeResponse(statusCode: 200))))
        let page = try await sut.load(query: "Metal", page: 1)
        #expect(page.items == [
            ArtistSearchResult(id: 1, name: "Metallica", thumbnailURL: URL(string: "https://img.discogs.com/1.jpg")),
            ArtistSearchResult(id: 2, name: "Megadeth",  thumbnailURL: URL(string: "https://img.discogs.com/2.jpg"))
        ])
        #expect(page.hasNextPage == true)
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
