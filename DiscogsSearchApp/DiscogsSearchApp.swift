import SwiftUI
import DiscogsSearch

@main
struct DiscogsSearchApp: App {
    private let detailLoader: any ArtistDetailLoader
    private let releasesLoader: any ArtistReleasesLoader

    @State private var searchViewModel: SearchViewModel

    init() {
        let token = Bundle.main.infoDictionary?["DiscogsAPIToken"] as? String ?? ""
        let session = URLSession(configuration: .ephemeral)
        let client: any HTTPClient = AuthenticatedHTTPClient(
            decoratee: URLSessionHTTPClient(session: session),
            token: token
        )
        let baseURL = URL(string: "https://api.discogs.com")!

        let searchLoader = RemoteArtistSearchLoader(client: client, baseURL: baseURL)
        detailLoader = RemoteArtistDetailLoader(client: client, baseURL: baseURL)
        releasesLoader = RemoteArtistReleasesLoader(client: client, baseURL: baseURL)
        _searchViewModel = State(initialValue: SearchViewModel(loader: searchLoader))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SearchView(viewModel: searchViewModel)
                    .navigationDestination(for: ArtistSearchResult.self) { artist in
                        ArtistDetailView(viewModel: ArtistDetailViewModel(
                            artistID: artist.id,
                            loader: detailLoader
                        ))
                    }
                    .navigationDestination(for: ReleasesTarget.self) { target in
                        ReleasesView(viewModel: ReleasesViewModel(
                            artistID: target.artistID,
                            loader: releasesLoader
                        ))
                    }
            }
        }
    }
}
