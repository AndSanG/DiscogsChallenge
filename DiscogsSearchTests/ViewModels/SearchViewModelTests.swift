import Testing
@testable import DiscogsSearch

@Suite @MainActor
struct SearchViewModelTests {

    // MARK: - init

    @Test func init_doesNotLoadArtists() {
        let (_, spy) = makeSUT()
        #expect(spy.loadCallCount == 0)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: SearchViewModel, spy: ArtistSearchLoaderSpy) {
        let spy = ArtistSearchLoaderSpy()
        let sut = SearchViewModel(loader: spy)
        return (sut, spy)
    }
}
