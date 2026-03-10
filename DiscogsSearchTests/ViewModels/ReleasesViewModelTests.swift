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

    @Test func load_deliversReleasesOnSuccess() async {
        let (sut, spy) = makeSUT()
        let expected = [anyRelease(id: 1, title: "OK Computer"), anyRelease(id: 2, title: "Kid A")]

        let task = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .success(makeReleasesPage(expected)))
        await task.value

        #expect(sut.releases == expected)
    }

    @Test func load_setsErrorMessageOnFailure() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .failure(anyError()))
        await task.value

        #expect(sut.errorMessage != nil)
    }

    @Test func load_clearsErrorBeforeReloading() async {
        let (sut, spy) = makeSUT()

        let task1 = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .failure(anyError()))
        await task1.value

        let task2 = Task { await sut.load() }
        await waitForTaskToStart()

        #expect(sut.errorMessage == nil)

        spy.complete(with: .success(emptyReleasesPage()))
        await task2.value
    }

    @Test func load_doesNotDeliverResultAfterSUTDeallocated() async {
        let spy = ArtistReleasesLoaderSpy()
        var sut: ReleasesViewModel? = ReleasesViewModel(artistID: 1, loader: spy)
        weak var weakSUT = sut

        let task = Task { await sut!.load() }
        await waitForTaskToStart()
        sut = nil
        spy.complete(with: .success(emptyReleasesPage()))
        await task.value

        #expect(weakSUT == nil, "Expected ReleasesViewModel to be deallocated — potential memory leak")
    }

    @Test func loadNextPage_appendsReleasesOnSuccess() async {
        let (sut, spy) = makeSUT()
        let firstPage = [anyRelease(id: 1, title: "Pablo Honey")]
        let secondPage = [anyRelease(id: 2, title: "The Bends")]

        let task1 = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .success(makeReleasesPage(firstPage, hasNextPage: true)))
        await task1.value

        let task2 = Task { await sut.loadNextPage() }
        await waitForTaskToStart()
        spy.complete(with: .success(makeReleasesPage(secondPage, hasNextPage: false)))
        await task2.value

        #expect(sut.releases == firstPage + secondPage)
    }

    // MARK: - Helpers

    private func makeSUT(artistID: Int = 1) -> (sut: ReleasesViewModel, spy: ArtistReleasesLoaderSpy) {
        let spy = ArtistReleasesLoaderSpy()
        let sut = ReleasesViewModel(artistID: artistID, loader: spy)
        return (sut, spy)
    }
}
