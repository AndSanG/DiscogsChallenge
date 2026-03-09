import SwiftUI

struct SearchView: View {
    @State private var query = ""

    private var artists: [PrototypeArtist] {
        query.isEmpty
            ? PrototypeData.artists
            : PrototypeData.artists.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        Group {
            if artists.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(artists) { artist in
                    NavigationLink(value: artist) {
                        ArtistRow(artist: artist)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $query, prompt: "Search artists…")
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: PrototypeArtist.self) { artist in
            ArtistDetailView(artist: artist)
        }
        .refreshable {
            try? await Task.sleep(for: .seconds(1.5))
        }
    }
}
