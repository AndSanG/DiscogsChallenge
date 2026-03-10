import Testing
@testable import DiscogsSearch

@Suite @MainActor
struct ReleasesViewModelTests {

    @Test func init_doesNotLoadReleases() {
        let (_, spy) = makeSUT()
        #expect(spy.loadCallCount == 0)
    }

    // MARK: - Helpers

    private func makeSUT(artistID: Int = 1) -> (sut: ReleasesViewModel, spy: ArtistReleasesLoaderSpy) {
        let spy = ArtistReleasesLoaderSpy()
        let sut = ReleasesViewModel(artistID: artistID, loader: spy)
        return (sut, spy)
    }
}
