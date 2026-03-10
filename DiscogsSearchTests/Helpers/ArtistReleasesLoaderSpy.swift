import Foundation
@testable import DiscogsSearch

final class ArtistReleasesLoaderSpy: ArtistReleasesLoader, @unchecked Sendable {
    private(set) var receivedRequests: [(artistID: Int, page: Int)] = []
    private var continuations: [CheckedContinuation<Page<Release>, Error>] = []

    func load(artistID: Int, page: Int) async throws -> Page<Release> {
        receivedRequests.append((artistID: artistID, page: page))
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func complete(with result: Result<Page<Release>, Error>) {
        guard !continuations.isEmpty else { return }
        continuations.removeFirst().resume(with: result)
    }

    var loadCallCount: Int { receivedRequests.count }
}

func emptyReleasesPage() -> Page<Release> {
    Page(items: [], hasNextPage: false)
}

func makeReleasesPage(_ items: [Release] = [], hasNextPage: Bool = false) -> Page<Release> {
    Page(items: items, hasNextPage: hasNextPage)
}

func anyRelease(id: Int = 1, title: String = "Any Album") -> Release {
    Release(id: id, title: title, year: 2000, genres: [], labels: [], thumbnailURL: nil, type: "master")
}
