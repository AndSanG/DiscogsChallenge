import SwiftUI

struct ArtistRow: View {
    let artist: PrototypeArtist

    @State private var isImageLoaded = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if isImageLoaded {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(avatarColor(for: artist.name))
                        .overlay(
                            Text(artist.name.prefix(1))
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                        )
                        .transition(.opacity)
                } else {
                    ShimmerView(cornerRadius: 6)
                }
            }
            .frame(width: 56, height: 56)
            .animation(.easeIn(duration: 0.35), value: isImageLoaded)

            VStack(alignment: .leading, spacing: 2) {
                Text(artist.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                if !artist.members.isEmpty {
                    Text("\(artist.members.count) members")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .task {
            let delay = Int.random(in: 400...1200)
            try? await Task.sleep(for: .milliseconds(delay))
            isImageLoaded = true
        }
    }

    private func avatarColor(for name: String) -> Color {
        let palette: [Color] = [.blue, .purple, .orange, .green, .pink, .teal, .indigo, .cyan]
        return palette[abs(name.hashValue) % palette.count]
    }
}
