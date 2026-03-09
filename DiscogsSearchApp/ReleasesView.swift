import SwiftUI
import DiscogsSearch

struct ReleasesView: View {
    var viewModel: ReleasesViewModel

    var body: some View {
        Group {
            if viewModel.releases.isEmpty && viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.releases.isEmpty && viewModel.errorMessage != nil {
                ContentUnavailableView(
                    "Could not load releases",
                    systemImage: "exclamationmark.triangle",
                    description: Text(viewModel.errorMessage ?? "")
                )
            } else {
                List {
                    ForEach(viewModel.releases, id: \.id) { release in
                        ReleaseRow(release: release)
                            .onAppear {
                                if release.id == viewModel.releases.last?.id {
                                    Task { await viewModel.loadNextPage() }
                                }
                            }
                    }

                    if viewModel.isLoading && !viewModel.releases.isEmpty {
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
        .navigationTitle("Releases")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil && !viewModel.releases.isEmpty },
            set: { _ in }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct ReleaseRow: View {
    let release: Release

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: release.thumbnailURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color(.systemGray5)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 3) {
                Text(release.title)
                    .font(.body)

                HStack(spacing: 4) {
                    if let year = release.year {
                        Text(String(year))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let label = release.labels.first {
                        Text("·").font(.caption).foregroundStyle(.secondary)
                        Text(label).font(.caption).foregroundStyle(.secondary)
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
