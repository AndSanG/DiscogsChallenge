import Observation

@Observable
@MainActor
public final class SearchViewModel {
    private let loader: any ArtistSearchLoader

    public private(set) var items: [ArtistSearchResult] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public private(set) var hasNextPage = false

    @ObservationIgnored private var currentQuery = ""
    @ObservationIgnored private var currentPage = 1
    @ObservationIgnored private var searchTask: Task<Void, Never>?

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

    public func onSearchTextChanged(_ text: String) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await self?.load(query: text)
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
