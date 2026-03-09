import SwiftUI
import DiscogsSearch

/// Navigation value used to push ReleasesView from the composition root.
struct ReleasesTarget: Hashable {
    let artistID: Int
}

struct ArtistDetailView: View {
    var viewModel: ArtistDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let artist = viewModel.artist {
                artistContent(artist)
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView(
                    "Could not load artist",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private func artistContent(_ artist: Artist) -> some View {
        List {
            // Hero image
            Section {
                AsyncImage(url: artist.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .listRowInsets(EdgeInsets())
            }

            // Profile
            if !artist.profile.isEmpty {
                Section("About") {
                    Text(artist.profile)
                        .font(.body)
                }
            }

            // Members
            if !artist.members.isEmpty {
                Section("Members") {
                    ForEach(artist.members, id: \.id) { member in
                        HStack {
                            Text(member.name)
                            Spacer()
                            if !member.isActive {
                                Text("Former")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            // Releases navigation — value handled by the Composition Root
            Section {
                NavigationLink(value: ReleasesTarget(artistID: artist.id)) {
                    Label("View Releases", systemImage: "music.note.list")
                }
            }
        }
        .navigationTitle(artist.name)
    }
}
