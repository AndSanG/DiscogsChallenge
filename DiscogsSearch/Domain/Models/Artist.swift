import Foundation

public struct Artist: Sendable, Equatable {
    public let id: Int
    public let name: String
    public let profile: String
    public let imageURL: URL?
    public let members: [Member]

    public init(id: Int, name: String, profile: String, imageURL: URL?, members: [Member]) {
        self.id = id
        self.name = name
        self.profile = profile
        self.imageURL = imageURL
        self.members = members
    }
}

public struct Member: Sendable, Equatable {
    public let id: Int
    public let name: String
    public let isActive: Bool

    public init(id: Int, name: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.isActive = isActive
    }
}
