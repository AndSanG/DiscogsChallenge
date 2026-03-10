import Foundation

enum ArtistDetailMapper {
    private struct Image: Decodable {
        let type: String
        let uri: String
    }

    private struct RemoteMember: Decodable {
        let id: Int
        let name: String
        let active: Bool?
    }

    private struct Root: Decodable {
        let id: Int
        let name: String
        let profile: String
        let images: [Image]?
        let members: [RemoteMember]?
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Artist {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteArtistDetailLoader.Error.invalidData
        }

        let primaryImage = root.images?.first { $0.type == "primary" }?.uri
            ?? root.images?.first?.uri
        let members = root.members?.map { Member(id: $0.id, name: $0.name, isActive: $0.active ?? true) } ?? []

        return Artist(
            id: root.id,
            name: root.name,
            profile: root.profile,
            imageURL: primaryImage.flatMap(URL.init(string:)),
            members: members
        )
    }
}
