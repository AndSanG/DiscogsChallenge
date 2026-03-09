import Foundation
import Testing
@testable import DiscogsSearch

@Suite("RemoteArtistDetailLoader")
struct RemoteArtistDetailLoaderTests {

    @Test func init_doesNotRequestData() {
        let (_, spy) = makeSUT()
        #expect(spy.requests.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        baseURL: URL = URL(string: "https://api.discogs.com")!
    ) -> (RemoteArtistDetailLoader, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        return (RemoteArtistDetailLoader(client: spy, baseURL: baseURL), spy)
    }
}
