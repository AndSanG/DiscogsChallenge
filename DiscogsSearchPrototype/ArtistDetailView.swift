import SwiftUI

struct ArtistDetailView: View {
    let artist: PrototypeArtist

    @State private var isHeroLoaded = false

    var body: some View {
        List {
            // Hero image
            Section {
                ZStack {
                    if isHeroLoaded {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(avatarColor(for: artist.name))
                            .overlay(
                                Text(artist.name.prefix(1))
                                    .font(.system(size: 72, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.8))
                            )
                            .transition(.opacity)
                    } else {
                        ShimmerView(cornerRadius: 12)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .animation(.easeIn(duration: 0.4), value: isHeroLoaded)
                .listRowInsets(EdgeInsets())
                .task {
                    try? await Task.sleep(for: .milliseconds(800))
                    isHeroLoaded = true
                }
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

    private func avatarColor(for name: String) -> Color {
        let palette: [Color] = [.blue, .purple, .orange, .green, .pink, .teal, .indigo, .cyan]
        return palette[abs(name.hashValue) % palette.count]
    }
}
