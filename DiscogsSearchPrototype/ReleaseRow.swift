import SwiftUI

struct ReleaseRow: View {
    let release: PrototypeRelease

    @State private var isImageLoaded = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if isImageLoaded {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(releaseColor(for: release.title))
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.8))
                        )
                        .transition(.opacity)
                } else {
                    ShimmerView(cornerRadius: 6)
                }
            }
            .frame(width: 56, height: 56)
            .animation(.easeIn(duration: 0.35), value: isImageLoaded)

            VStack(alignment: .leading, spacing: 3) {
                Text(release.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    if let year = release.year {
                        Text(String(year))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let label = release.labels.first {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let genre = release.genres.first {
                    Text(genre)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
        .task {
            let delay = Int.random(in: 300...1000)
            try? await Task.sleep(for: .milliseconds(delay))
            isImageLoaded = true
        }
    }

    private func releaseColor(for title: String) -> Color {
        let palette: [Color] = [.indigo, .teal, .orange, .purple, .blue, .green, .pink]
        return palette[abs(title.hashValue) % palette.count]
    }
}
