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


    @Test func load_deliversConnectivityErrorOnClientError() async {
        let (sut, spy) = makeSUT()
        spy.stub(.failure(anyError()))

        await #expect(throws: RemoteArtistReleasesLoader.Error.connectivity) {
            _ = try await sut.load(artistID: 1, page: 1)
        }
    }


    @Test("delivers .invalidData on non-200 response", arguments: [199, 201, 400, 500])
    func load_deliversInvalidDataErrorOnNon200Response(statusCode: Int) async {
        let (sut, spy) = makeSUT()
        spy.stub(.success((makeReleasesJSON(), makeResponse(statusCode: statusCode))))

        await #expect(throws: RemoteArtistReleasesLoader.Error.invalidData) {
            _ = try await sut.load(artistID: 1, page: 1)
        }
    }


    @Test func load_deliversInvalidDataOn200WithInvalidJSON() async {
        let (sut, spy) = makeSUT()
        spy.stub(.success((anyData(), makeResponse(statusCode: 200))))

        await #expect(throws: RemoteArtistReleasesLoader.Error.invalidData) {
            _ = try await sut.load(artistID: 1, page: 1)
        }
    }


    @Test func load_deliversNoReleasesOn200WithEmptyList() async throws {
        let (sut, spy) = makeSUT()
        spy.stub(.success((makeReleasesJSON([]), makeResponse(statusCode: 200))))

        let page = try await sut.load(artistID: 1, page: 1)

        #expect(page.items.isEmpty)
        #expect(page.hasNextPage == false)
    }


    @Test func load_deliversReleasesOn200WithValidJSON() async throws {
        let (sut, spy) = makeSUT()
        let release1 = makeReleaseItem(id: 1, title: "Master of Puppets", year: 1986,
                                       genres: ["Rock"], labels: ["Elektra"],
                                       thumb: "https://img.discogs.com/1.jpg", type: "master")
        let release2 = makeReleaseItem(id: 2, title: "...And Justice for All", year: 1988,
                                       genres: ["Metal"], labels: ["Elektra"],
                                       thumb: "https://img.discogs.com/2.jpg", type: "master")
        spy.stub(.success((makeReleasesJSON([release1, release2], page: 1, pages: 3),
                           makeResponse(statusCode: 200))))

        let page = try await sut.load(artistID: 1, page: 1)

        #expect(page.items == [
            Release(id: 1, title: "Master of Puppets", year: 1986,
                    genres: ["Rock"], labels: ["Elektra"],
                    thumbnailURL: URL(string: "https://img.discogs.com/1.jpg"), type: "master"),
            Release(id: 2, title: "...And Justice for All", year: 1988,
                    genres: ["Metal"], labels: ["Elektra"],
                    thumbnailURL: URL(string: "https://img.discogs.com/2.jpg"), type: "master")
        ])
        #expect(page.hasNextPage == true)
    }


    @Test func load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        var sut: RemoteArtistReleasesLoader? = RemoteArtistReleasesLoader(
            client: HTTPClientSpy(), baseURL: anyURL()
        )
        weak var weakSUT = sut
        sut = nil
        #expect(weakSUT == nil, "Expected loader to be deallocated — potential retain cycle")
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
