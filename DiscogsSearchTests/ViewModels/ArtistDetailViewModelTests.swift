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

    // MARK: - Helpers

    private func makeSUT(artistID: Int = 1) -> (sut: ArtistDetailViewModel, spy: ArtistDetailLoaderSpy) {
        let spy = ArtistDetailLoaderSpy()
        let sut = ArtistDetailViewModel(artistID: artistID, loader: spy)
        return (sut, spy)
    }
}
