import SwiftUI
import DiscogsSearch

struct SearchView: View {
    var viewModel: SearchViewModel

    @State private var searchText = ""

    var body: some View {
        Group {
            if viewModel.items.isEmpty && !viewModel.isLoading && searchText.isEmpty {
                ContentUnavailableView(
                    "Search for an Artist",
                    systemImage: "magnifyingglass",
                    description: Text("Type an artist name to get started.")
                )
            } else if viewModel.items.isEmpty && !viewModel.isLoading {
                ContentUnavailableView.search(text: searchText)
            } else {
                List {
                    ForEach(viewModel.items, id: \.id) { artist in
                        NavigationLink(value: artist) {
                            ArtistRow(artist: artist)
                        }
                        .onAppear {
                            if artist.id == viewModel.items.last?.id {
                                Task { await viewModel.loadNextPage() }
                            }
                        }
                    }

                    if viewModel.isLoading && !viewModel.items.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .overlay(alignment: .top) {
            if viewModel.isLoading && viewModel.items.isEmpty { ProgressView().padding(.top, 8) }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search artists…")
        .onChange(of: searchText) { _, newValue in
            viewModel.onSearchTextChanged(newValue)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .refreshable {
            await viewModel.load(query: searchText)
        }
    }
}

private struct ArtistRow: View {
    let artist: ArtistSearchResult

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: artist.thumbnailURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color(.systemGray5)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(artist.name)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}
