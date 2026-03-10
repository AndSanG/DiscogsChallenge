import Foundation

enum ArtistSearchMapper {
    private struct Item: Decodable {
        let id: Int
        let title: String
        let thumb: String
    }

    private struct Pagination: Decodable {
        let page: Int
        let pages: Int
    }

    private struct Root: Decodable {
        let results: [Item]
        let pagination: Pagination
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Page<ArtistSearchResult> {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteArtistSearchLoader.Error.invalidData
        }

        let items = root.results.map { item in
            ArtistSearchResult(
                id: item.id,
                name: item.title,
                thumbnailURL: URL(string: item.thumb)
            )
        }
        return Page(items: items, hasNextPage: root.pagination.page < root.pagination.pages)
    }
}
