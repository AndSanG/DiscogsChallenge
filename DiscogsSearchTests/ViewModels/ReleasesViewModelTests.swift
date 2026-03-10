import Testing
@testable import DiscogsSearch

@Suite @MainActor
struct ReleasesViewModelTests {

    @Test func init_doesNotLoadReleases() {
        let (_, spy) = makeSUT()
        #expect(spy.loadCallCount == 0)
    }

    @Test func load_requestsReleasesFromLoader() async {
        let (sut, spy) = makeSUT(artistID: 7)

        let task = Task { await sut.load() }
        await waitForTaskToStart()

        #expect(spy.loadCallCount == 1)
        #expect(spy.receivedRequests.first?.artistID == 7)
        #expect(spy.receivedRequests.first?.page == 1)

        spy.complete(with: .success(emptyReleasesPage()))
        await task.value
    }

    @Test func load_setsIsLoadingDuringRequest() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load() }
        await waitForTaskToStart()

        #expect(sut.isLoading == true)

        spy.complete(with: .success(emptyReleasesPage()))
        await task.value
    }

    @Test func load_clearsIsLoadingOnSuccess() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .success(emptyReleasesPage()))
        await task.value

        #expect(sut.isLoading == false)
    }

    @Test func load_clearsIsLoadingOnFailure() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .failure(anyError()))
        await task.value

        #expect(sut.isLoading == false)
    }

    // MARK: - Helpers

    private func makeSUT(artistID: Int = 1) -> (sut: ReleasesViewModel, spy: ArtistReleasesLoaderSpy) {
        let spy = ArtistReleasesLoaderSpy()
        let sut = ReleasesViewModel(artistID: artistID, loader: spy)
        return (sut, spy)
    }
}
