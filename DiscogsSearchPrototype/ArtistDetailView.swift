import SwiftUI

struct ArtistDetailView: View {
    let artist: PrototypeArtist

    var body: some View {
        List {
            // Hero image placeholder
            Section {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .listRowInsets(EdgeInsets())
            }

            // Profile
            Section("About") {
                Text(artist.profile)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            // Members
            if !artist.members.isEmpty {
                Section("Members") {
                    ForEach(artist.members) { member in
                        HStack {
                            Text(member.name)
                                .font(.body)
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

            // Releases navigation
            Section {
                NavigationLink {
                    ReleasesView(artistName: artist.name)
                } label: {
                    Label("View Releases", systemImage: "music.note.list")
                }
            }
        }
        .navigationTitle(artist.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
