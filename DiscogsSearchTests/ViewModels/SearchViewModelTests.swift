import Testing
@testable import DiscogsSearch

@Suite @MainActor
struct SearchViewModelTests {

    // MARK: - init

    @Test func init_doesNotLoadArtists() {
        let (_, spy) = makeSUT()
        #expect(spy.loadCallCount == 0)
    }

    @Test func load_requestsArtistsFromLoader() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load(query: "Radiohead") }
        await Task.yield()

        #expect(spy.loadCallCount == 1)
        #expect(spy.receivedQueries.first?.query == "Radiohead")
        #expect(spy.receivedQueries.first?.page == 1)

        spy.complete(with: .success(emptySearchPage()))
        await task.value
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: SearchViewModel, spy: ArtistSearchLoaderSpy) {
        let spy = ArtistSearchLoaderSpy()
        let sut = SearchViewModel(loader: spy)
        return (sut, spy)
    }
}
