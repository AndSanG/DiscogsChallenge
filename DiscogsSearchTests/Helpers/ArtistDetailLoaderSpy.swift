import Foundation
@testable import DiscogsSearch

final class ArtistDetailLoaderSpy: ArtistDetailLoader, @unchecked Sendable {
    private(set) var receivedArtistIDs: [Int] = []
    private var continuations: [CheckedContinuation<Artist, Error>] = []

    func load(artistID: Int) async throws -> Artist {
        receivedArtistIDs.append(artistID)
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func complete(with result: Result<Artist, Error>) {
        guard !continuations.isEmpty else { return }
        continuations.removeFirst().resume(with: result)
    }

    var loadCallCount: Int { receivedArtistIDs.count }
}

func anyArtist(id: Int = 1, name: String = "Any Artist") -> Artist {
    Artist(id: id, name: name, profile: "Any profile", imageURL: nil, members: [])
}
