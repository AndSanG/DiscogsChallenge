import SwiftUI

struct ReleaseRow: View {
    let release: PrototypeRelease

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemGray5))
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 3) {
                Text(release.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
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
    }
}
