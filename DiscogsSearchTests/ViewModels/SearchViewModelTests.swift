import Testing
@testable import DiscogsSearch

@Suite @MainActor
struct SearchViewModelTests {

    // MARK: - init

    @Test func init_doesNotLoadArtists() {
        let (_, spy) = makeSUT()
        #expect(spy.loadCallCount == 0)
    }

    // MARK: - load

    @Test func load_requestsArtistsFromLoader() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load(query: "Radiohead") }
        await waitForTaskToStart()

        #expect(spy.loadCallCount == 1)
        #expect(spy.receivedQueries.first?.query == "Radiohead")
        #expect(spy.receivedQueries.first?.page == 1)

        spy.complete(with: .success(emptySearchPage()))
        await task.value
    }

    @Test func load_setsIsLoadingDuringRequest() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load(query: "Radiohead") }
        await waitForTaskToStart()

        #expect(sut.isLoading == true)

        spy.complete(with: .success(emptySearchPage()))
        await task.value
    }

    @Test func load_clearsIsLoadingOnSuccess() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load(query: "Radiohead") }
        await waitForTaskToStart()
        spy.complete(with: .success(emptySearchPage()))
        await task.value

        #expect(sut.isLoading == false)
    }

    @Test func load_clearsIsLoadingOnFailure() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load(query: "Radiohead") }
        await waitForTaskToStart()
        spy.complete(with: .failure(anyError()))
        await task.value

        #expect(sut.isLoading == false)
    }

    @Test func load_deliversArtistsOnSuccess() async {
        let (sut, spy) = makeSUT()
        let expected = [anySearchResult(id: 1, name: "Radiohead"), anySearchResult(id: 2, name: "Daft Punk")]

        let task = Task { await sut.load(query: "any") }
        await waitForTaskToStart()
        spy.complete(with: .success(makeSearchResults(expected)))
        await task.value

        #expect(sut.items == expected)
    }

    @Test func load_setsErrorMessageOnFailure() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load(query: "any") }
        await waitForTaskToStart()
        spy.complete(with: .failure(anyError()))
        await task.value

        #expect(sut.errorMessage != nil)
    }

    @Test func load_clearsErrorBeforeReloading() async {
        let (sut, spy) = makeSUT()

        // First load → failure sets errorMessage
        let task1 = Task { await sut.load(query: "any") }
        await waitForTaskToStart()
        spy.complete(with: .failure(anyError()))
        await task1.value

        // Second load → errorMessage must be nil before the new request resolves
        let task2 = Task { await sut.load(query: "any") }
        await waitForTaskToStart()

        #expect(sut.errorMessage == nil)

        spy.complete(with: .success(emptySearchPage()))
        await task2.value
    }

    @Test func load_doesNotDeliverResultAfterSUTDeallocated() async {
        let spy = ArtistSearchLoaderSpy()
        var sut: SearchViewModel? = SearchViewModel(loader: spy)
        weak var weakSUT = sut

        let task = Task { await sut!.load(query: "any") }
        await waitForTaskToStart()
        sut = nil
        spy.complete(with: .success(emptySearchPage()))
        await task.value

        #expect(weakSUT == nil, "Expected SearchViewModel to be deallocated — potential memory leak")
    }

    // MARK: - loadNextPage

    @Test func loadNextPage_appendsArtistsOnSuccess() async {
        let (sut, spy) = makeSUT()
        let firstPage = [anySearchResult(id: 1, name: "Artist A")]
        let secondPage = [anySearchResult(id: 2, name: "Artist B")]

        // Load page 1
        let task1 = Task { await sut.load(query: "any") }
        await waitForTaskToStart()
        spy.complete(with: .success(makeSearchResults(firstPage, hasNextPage: true)))
        await task1.value

        // Load page 2
        let task2 = Task { await sut.loadNextPage() }
        await waitForTaskToStart()
        spy.complete(with: .success(makeSearchResults(secondPage, hasNextPage: false)))
        await task2.value

        #expect(sut.items == firstPage + secondPage)
    }

    @Test func loadNextPage_doesNothingWhenOnLastPage() async {
        let (sut, spy) = makeSUT()

        // Load page 1 with hasNextPage = false
        let task1 = Task { await sut.load(query: "any") }
        await waitForTaskToStart()
        spy.complete(with: .success(makeSearchResults([], hasNextPage: false)))
        await task1.value

        await sut.loadNextPage()

        #expect(spy.loadCallCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: SearchViewModel, spy: ArtistSearchLoaderSpy) {
        let spy = ArtistSearchLoaderSpy()
        let sut = SearchViewModel(loader: spy)
        return (sut, spy)
    }
}
