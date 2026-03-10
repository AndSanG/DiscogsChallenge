import Observation

@Observable
@MainActor
public final class ReleasesViewModel {
    private let artistID: Int
    private let loader: any ArtistReleasesLoader

    @ObservationIgnored private var currentPage = 1

    public private(set) var isLoading = false
    public private(set) var releases: [Release] = []
    public private(set) var errorMessage: String? = nil

    public init(artistID: Int, loader: any ArtistReleasesLoader) {
        self.artistID = artistID
        self.loader = loader
    }

    public func load() async {
        errorMessage = nil
        isLoading = true
        currentPage = 1
        defer { isLoading = false }
        do {
            let page = try await loader.load(artistID: artistID, page: currentPage)
            releases = page.items
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
