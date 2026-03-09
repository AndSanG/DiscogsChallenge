import Foundation

public protocol ArtistDetailLoader: Sendable {
    func load(artistID: Int) async throws -> Artist
}
