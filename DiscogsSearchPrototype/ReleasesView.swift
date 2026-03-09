import SwiftUI

struct ReleasesView: View {
    let artistName: String

    var body: some View {
        List(PrototypeData.releases) { release in
            ReleaseRow(release: release)
        }
        .listStyle(.plain)
        .navigationTitle("Releases")
        .navigationBarTitleDisplayMode(.large)
    }
}
