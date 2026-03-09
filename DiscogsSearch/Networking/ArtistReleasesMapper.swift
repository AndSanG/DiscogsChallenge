import Foundation

enum ArtistReleasesMapper {
    private struct Root: Decodable {
        let releases: [Item]
        let pagination: Pagination

        struct Item: Decodable {
            let id: Int
            let title: String
            let year: Int?
            let genres: [String]?
            let labels: [Label]?
            let thumb: String?
            let type: String

            struct Label: Decodable {
                let name: String
            }
        }

        struct Pagination: Decodable {
            let page: Int
            let pages: Int
        }
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Page<Release> {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteArtistReleasesLoader.Error.invalidData
        }

        let items = root.releases.map { item in
            Release(
                id: item.id,
                title: item.title,
                year: item.year,
                genres: item.genres ?? [],
                labels: item.labels?.map(\.name) ?? [],
                thumbnailURL: item.thumb.flatMap(URL.init(string:)),
                type: item.type
            )
        }
        return Page(items: items, hasNextPage: root.pagination.page < root.pagination.pages)
    }
}
