import Observation

@Observable
@MainActor
public final class ArtistDetailViewModel {
    private let artistID: Int
    private let loader: any ArtistDetailLoader

    public private(set) var artist: Artist?
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    public init(artistID: Int, loader: any ArtistDetailLoader) {
        self.artistID = artistID
        self.loader = loader
    }

    public func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            artist = try await loader.load(artistID: artistID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
