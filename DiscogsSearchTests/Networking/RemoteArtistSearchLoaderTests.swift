import Foundation
import Testing
@testable import DiscogsSearch

@Suite("RemoteArtistSearchLoader")
struct RemoteArtistSearchLoaderTests {

    @Test func init_doesNotRequestData() {
        let (_, spy) = makeSUT()
        #expect(spy.requests.isEmpty)
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
