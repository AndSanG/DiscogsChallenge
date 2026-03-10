import SwiftUI
import DiscogsSearch

struct ReleasesView: View {
    var viewModel: ReleasesViewModel

    @State private var showingFilter = false

    var body: some View {
        Group {
            if viewModel.filteredReleases.isEmpty && viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredReleases.isEmpty && viewModel.errorMessage != nil {
                ContentUnavailableView(
                    "Could not load releases",
                    systemImage: "exclamationmark.triangle",
                    description: Text(viewModel.errorMessage ?? "")
                )
            } else if viewModel.filteredReleases.isEmpty && !viewModel.releases.isEmpty {
                ContentUnavailableView(
                    "No Matching Releases",
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text("Try adjusting or clearing your filters.")
                )
            } else {
                List {
                    ForEach(viewModel.filteredReleases, id: \.id) { release in
                        ReleaseRow(release: release)
                            .onAppear {
                                if release.id == viewModel.filteredReleases.last?.id {
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingFilter = true
                } label: {
                    let hasActiveFilters = viewModel.activeYearFilter != nil
                        || viewModel.activeGenreFilter != nil
                        || viewModel.activeLabelFilter != nil
                    Label(
                        "Filter",
                        systemImage: hasActiveFilters
                            ? "line.3.horizontal.decrease.circle.fill"
                            : "line.3.horizontal.decrease.circle"
                    )
                }
            }
        }
        .task { await viewModel.load() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil && !viewModel.releases.isEmpty },
            set: { _ in }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showingFilter) {
            FilterSheet(viewModel: viewModel)
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

private struct FilterSheet: View {
    var viewModel: ReleasesViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if !viewModel.availableYears.isEmpty {
                    Section("Year") {
                        Picker("Year", selection: Binding(
                            get: { viewModel.activeYearFilter },
                            set: { viewModel.applyYearFilter($0) }
                        )) {
                            Text("All").tag(Optional<Int>.none)
                            ForEach(viewModel.availableYears, id: \.self) { year in
                                Text(String(year)).tag(Optional(year))
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }

                if !viewModel.availableGenres.isEmpty {
                    Section("Genre") {
                        Picker("Genre", selection: Binding(
                            get: { viewModel.activeGenreFilter },
                            set: { viewModel.applyGenreFilter($0) }
                        )) {
                            Text("All").tag(Optional<String>.none)
                            ForEach(viewModel.availableGenres, id: \.self) { genre in
                                Text(genre).tag(Optional(genre))
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }

                if !viewModel.availableLabels.isEmpty {
                    Section("Label") {
                        Picker("Label", selection: Binding(
                            get: { viewModel.activeLabelFilter },
                            set: { viewModel.applyLabelFilter($0) }
                        )) {
                            Text("All").tag(Optional<String>.none)
                            ForEach(viewModel.availableLabels, id: \.self) { label in
                                Text(label).tag(Optional(label))
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
            }
            .navigationTitle("Filter Releases")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") { viewModel.clearFilters() }
                        .disabled(
                            viewModel.activeYearFilter == nil &&
                            viewModel.activeGenreFilter == nil &&
                            viewModel.activeLabelFilter == nil
                        )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
