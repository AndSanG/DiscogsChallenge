import Foundation

public struct Release: Sendable, Equatable {
    public let id: Int
    public let title: String
    public let year: Int?
    public let genres: [String]
    public let labels: [String]
    public let thumbnailURL: URL?
    public let type: String

    public init(
        id: Int,
        title: String,
        year: Int?,
        genres: [String],
        labels: [String],
        thumbnailURL: URL?,
        type: String
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.genres = genres
        self.labels = labels
        self.thumbnailURL = thumbnailURL
        self.type = type
    }
}
