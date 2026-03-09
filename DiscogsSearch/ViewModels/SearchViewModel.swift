import Observation

@Observable
@MainActor
public final class SearchViewModel {
    private let loader: any ArtistSearchLoader

    public private(set) var items: [ArtistSearchResult] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String? = nil

    public init(loader: any ArtistSearchLoader) {
        self.loader = loader
    }

    public func load(query: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await loader.load(query: query, page: 1)
            items = page.items
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
