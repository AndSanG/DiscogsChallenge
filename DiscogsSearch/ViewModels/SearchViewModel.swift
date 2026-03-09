import Observation

@Observable
@MainActor
public final class SearchViewModel {
    private let loader: any ArtistSearchLoader

    public private(set) var items: [ArtistSearchResult] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String? = nil
    public private(set) var hasNextPage = false

    @ObservationIgnored private var currentQuery = ""
    @ObservationIgnored private var currentPage = 1

    public init(loader: any ArtistSearchLoader) {
        self.loader = loader
    }

    public func load(query: String) async {
        errorMessage = nil
        isLoading = true
        currentQuery = query
        currentPage = 1
        defer { isLoading = false }
        do {
            let page = try await loader.load(query: query, page: currentPage)
            items = page.items
            hasNextPage = page.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func loadNextPage() async {
        guard hasNextPage, !isLoading else { return }
        currentPage += 1
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await loader.load(query: currentQuery, page: currentPage)
            items += page.items
            hasNextPage = page.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
