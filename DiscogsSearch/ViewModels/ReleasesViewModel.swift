import Observation

@Observable
@MainActor
public final class ReleasesViewModel {
    private let artistID: Int
    private let loader: any ArtistReleasesLoader

    @ObservationIgnored private var currentPage = 1

    public private(set) var isLoading = false
    public private(set) var releases: [Release] = []

    public init(artistID: Int, loader: any ArtistReleasesLoader) {
        self.artistID = artistID
        self.loader = loader
    }

    public func load() async {
        isLoading = true
        currentPage = 1
        if let page = try? await loader.load(artistID: artistID, page: currentPage) {
            releases = page.items
        }
        isLoading = false
    }
}
