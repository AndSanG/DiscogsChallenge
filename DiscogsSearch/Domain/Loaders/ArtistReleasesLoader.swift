import Foundation

public protocol ArtistReleasesLoader: Sendable {
    func load(artistID: Int, page: Int) async throws -> Page<Release>
}
