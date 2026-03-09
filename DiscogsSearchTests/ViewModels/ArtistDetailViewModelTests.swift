import Testing
@testable import DiscogsSearch

@Suite @MainActor
struct ArtistDetailViewModelTests {

    @Test func init_doesNotLoadArtist() {
        let (_, spy) = makeSUT()
        #expect(spy.loadCallCount == 0)
    }

    // MARK: - Helpers

    private func makeSUT(artistID: Int = 1) -> (sut: ArtistDetailViewModel, spy: ArtistDetailLoaderSpy) {
        let spy = ArtistDetailLoaderSpy()
        let sut = ArtistDetailViewModel(artistID: artistID, loader: spy)
        return (sut, spy)
    }
}
