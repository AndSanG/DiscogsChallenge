import Observation

@Observable
@MainActor
public final class SearchViewModel {
    private let loader: any ArtistSearchLoader

    public private(set) var isLoading = false

    public init(loader: any ArtistSearchLoader) {
        self.loader = loader
    }

    public func load(query: String) async {
        isLoading = true
        defer { isLoading = false }
        _ = try? await loader.load(query: query, page: 1)
    }
}
