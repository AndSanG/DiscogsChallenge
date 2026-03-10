import Observation

@Observable
@MainActor
public final class ReleasesViewModel {
    private let artistID: Int
    private let loader: any ArtistReleasesLoader

    @ObservationIgnored private var currentPage = 1

    public private(set) var isLoading = false
    public private(set) var releases: [Release] = []
    public private(set) var errorMessage: String?
    public private(set) var hasNextPage = false

    public private(set) var activeYearFilter: Int?
    public private(set) var activeGenreFilter: String?
    public private(set) var activeLabelFilter: String?

    public var filteredReleases: [Release] {
        releases.filter { release in
            (activeYearFilter == nil || release.year == activeYearFilter) &&
            (activeGenreFilter.map { release.genres.contains($0) } ?? true) &&
            (activeLabelFilter.map { release.labels.contains($0) } ?? true)
        }
    }

    public func applyYearFilter(_ year: Int?) {
        activeYearFilter = year
    }

    public func applyGenreFilter(_ genre: String?) {
        activeGenreFilter = genre
    }

    public func applyLabelFilter(_ label: String?) {
        activeLabelFilter = label
    }

    public func clearFilters() {
        activeYearFilter = nil
        activeGenreFilter = nil
        activeLabelFilter = nil
    }

    public var availableYears: [Int] {
        Array(Set(releases.compactMap(\.year))).sorted(by: >)
    }

    public var availableGenres: [String] {
        Array(Set(releases.flatMap(\.genres))).sorted()
    }

    public init(artistID: Int, loader: any ArtistReleasesLoader) {
        self.artistID = artistID
        self.loader = loader
    }

    public func load() async {
        errorMessage = nil
        isLoading = true
        currentPage = 1
        defer { isLoading = false }
        do {
            let page = try await loader.load(artistID: artistID, page: currentPage)
            releases = page.items
            hasNextPage = page.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func loadNextPage() async {
        guard hasNextPage, !isLoading else { return }
        currentPage += 1
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await loader.load(artistID: artistID, page: currentPage)
            releases += page.items
            hasNextPage = page.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
