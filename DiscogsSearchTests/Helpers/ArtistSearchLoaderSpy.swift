import Foundation
@testable import DiscogsSearch

final class ArtistSearchLoaderSpy: ArtistSearchLoader, @unchecked Sendable {
    private(set) var receivedQueries: [(query: String, page: Int)] = []
    private var continuations: [CheckedContinuation<Page<ArtistSearchResult>, Error>] = []

    func load(query: String, page: Int) async throws -> Page<ArtistSearchResult> {
        receivedQueries.append((query: query, page: page))
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func complete(with result: Result<Page<ArtistSearchResult>, Error>) {
        guard !continuations.isEmpty else { return }
        continuations.removeFirst().resume(with: result)
    }

    var loadCallCount: Int { receivedQueries.count }
}

func emptySearchPage() -> Page<ArtistSearchResult> {
    Page(items: [], hasNextPage: false)
}

func makeSearchResults(_ items: [ArtistSearchResult] = [], hasNextPage: Bool = false) -> Page<ArtistSearchResult> {
    Page(items: items, hasNextPage: hasNextPage)
}

func anySearchResult(id: Int = 1, name: String = "Any Artist") -> ArtistSearchResult {
    ArtistSearchResult(id: id, name: name, thumbnailURL: nil)
}
