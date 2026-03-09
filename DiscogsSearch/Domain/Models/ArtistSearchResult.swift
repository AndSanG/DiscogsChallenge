import Foundation

public struct ArtistSearchResult: Sendable, Equatable {
    public let id: Int
    public let name: String
    public let thumbnailURL: URL?

    public init(id: Int, name: String, thumbnailURL: URL?) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
    }
}
