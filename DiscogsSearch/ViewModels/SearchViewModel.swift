import Observation

@Observable
@MainActor
public final class SearchViewModel {
    private let loader: any ArtistSearchLoader

    public init(loader: any ArtistSearchLoader) {
        self.loader = loader
    }

    public func load(query: String) async {
        _ = try? await loader.load(query: query, page: 1)
    }
}
