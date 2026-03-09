import Foundation
import Testing
@testable import DiscogsSearch

@Suite("RemoteArtistDetailLoader")
struct RemoteArtistDetailLoaderTests {

    @Test func init_doesNotRequestData() {
        let (_, spy) = makeSUT()
        #expect(spy.requests.isEmpty)
    }


    @Test func load_requestsCorrectURL() async throws {
        let baseURL = URL(string: "https://api.discogs.com")!
        let (sut, spy) = makeSUT(baseURL: baseURL)
        spy.stub(.success((makeArtistJSON(), makeResponse(statusCode: 200))))
        _ = try await sut.load(artistID: 123)
        #expect(spy.requests.count == 1)
        let url = try #require(spy.requests.first?.url)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.path == "/artists/123")
    }

    // MARK: - Helpers

    private func makeSUT(
        baseURL: URL = URL(string: "https://api.discogs.com")!
    ) -> (RemoteArtistDetailLoader, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        return (RemoteArtistDetailLoader(client: spy, baseURL: baseURL), spy)
    }
    private func makeArtistJSON(id: Int = 1, name: String = "Any Artist", profile: String = "",
                                imageURI: String = "", members: [[String: Any]] = []) -> Data {
        var json: [String: Any] = ["id": id, "name": name, "profile": profile,
            "images": imageURI.isEmpty ? [] : [["type": "primary", "uri": imageURI]]]
        if !members.isEmpty { json["members"] = members }
        return try! JSONSerialization.data(withJSONObject: json)
    }

}