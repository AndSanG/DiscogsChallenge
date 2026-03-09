import Observation

@Observable
@MainActor
public final class ArtistDetailViewModel {
    private let artistID: Int
    private let loader: any ArtistDetailLoader

    public init(artistID: Int, loader: any ArtistDetailLoader) {
        self.artistID = artistID
        self.loader = loader
    }
}
