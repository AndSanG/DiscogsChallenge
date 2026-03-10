import Observation

@Observable
@MainActor
public final class ReleasesViewModel {
    private let artistID: Int
    private let loader: any ArtistReleasesLoader

    public init(artistID: Int, loader: any ArtistReleasesLoader) {
        self.artistID = artistID
        self.loader = loader
    }

    public func load() async {}
}
