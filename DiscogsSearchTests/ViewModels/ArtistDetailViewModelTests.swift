import Testing
@testable import DiscogsSearch

@Suite @MainActor
struct ArtistDetailViewModelTests {

    @Test func init_doesNotLoadArtist() {
        let (_, spy) = makeSUT()
        #expect(spy.loadCallCount == 0)
    }

    @Test func load_requestsArtistFromLoader() async {
        let (sut, spy) = makeSUT(artistID: 42)

        let task = Task { await sut.load() }
        await waitForTaskToStart()

        #expect(spy.loadCallCount == 1)
        #expect(spy.receivedArtistIDs.first == 42)

        spy.complete(with: .success(anyArtist()))
        await task.value
    }

    @Test func load_setsIsLoadingDuringRequest() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load() }
        await waitForTaskToStart()

        #expect(sut.isLoading == true)

        spy.complete(with: .success(anyArtist()))
        await task.value
    }

    @Test func load_clearsIsLoadingOnSuccess() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .success(anyArtist()))
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

    @Test func load_deliversArtistOnSuccess() async {
        let (sut, spy) = makeSUT()
        let expected = anyArtist(id: 99, name: "Radiohead")

        let task = Task { await sut.load() }
        await waitForTaskToStart()
        spy.complete(with: .success(expected))
        await task.value

        #expect(sut.artist == expected)
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

        spy.complete(with: .success(anyArtist()))
        await task2.value
    }

    @Test func load_doesNotDeliverResultAfterSUTDeallocated() async {
        let spy = ArtistDetailLoaderSpy()
        var sut: ArtistDetailViewModel? = ArtistDetailViewModel(artistID: 1, loader: spy)
        weak var weakSUT = sut

        let task = Task { await sut!.load() }
        await waitForTaskToStart()
        sut = nil
        spy.complete(with: .success(anyArtist()))
        await task.value

        #expect(weakSUT == nil, "Expected ArtistDetailViewModel to be deallocated — potential memory leak")
    }

    // MARK: - Helpers

    private func makeSUT(artistID: Int = 1) -> (sut: ArtistDetailViewModel, spy: ArtistDetailLoaderSpy) {
        let spy = ArtistDetailLoaderSpy()
        let sut = ArtistDetailViewModel(artistID: artistID, loader: spy)
        return (sut, spy)
    }
}
