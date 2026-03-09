# DiscogsSearch

An iOS app for searching artists, browsing their profiles, and exploring their releases using the [Discogs API](https://www.discogs.com/developers).

---

## How to run the project

### Prerequisites
- Xcode 16.3+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- A Discogs personal access token from [discogs.com/settings/developers](https://www.discogs.com/settings/developers)

### Setup
```bash
git clone <repo-url>
cd DiscogsChallenge

# Copy the token template and add your token
cp Configuration/Secrets.xcconfig.template Configuration/Secrets.xcconfig
# Edit Secrets.xcconfig and replace REPLACE_WITH_YOUR_TOKEN

# Generate the Xcode project
xcodegen generate

open DiscogsSearch.xcodeproj
```

### Run the tests
```bash
# Domain + infrastructure tests (macOS, no simulator needed)
xcodebuild test -scheme DiscogsSearchTests -destination "platform=macOS"

# End-to-end API tests (requires DISCOGS_API_TOKEN env var)
DISCOGS_API_TOKEN=your_token xcodebuild test \
  -scheme DiscogsSearchAPIEndToEndTests \
  -destination "platform=macOS"
```

---

## Architecture and reasoning

The project uses a strict layered architecture where each module depends only on abstractions (protocols), never on concrete implementations in other modules.

```
DiscogsSearchApp (iOS)       ← Composition Root only; wires everything together
       │
       ▼
DiscogsSearch (macOS framework)
  ├── Domain
  │    ├── Models:   ArtistSearchResult, Artist, Member, Release, Page<T>
  │    └── Loaders:  ArtistSearchLoader, ArtistDetailLoader, ArtistReleasesLoader (protocols)
  └── Networking
       ├── HTTPClient (protocol)
       ├── URLSessionHTTPClient (concrete)
       ├── RemoteArtistSearchLoader
       ├── RemoteArtistDetailLoader
       ├── RemoteArtistReleasesLoader
       └── Mappers: ArtistSearchMapper, ArtistDetailMapper, ArtistReleasesMapper
```

**Why a macOS framework for domain logic?**
Domain and networking layers have no platform-specific dependencies. Targeting macOS lets the entire test suite run natively in seconds without launching a simulator — the fastest possible feedback loop.

---

## How Dependency Injection works

Every concrete type receives its dependencies through its initialiser — no singletons, no global state.

```swift
// The loader depends on a protocol, not URLSession
let loader = RemoteArtistSearchLoader(client: URLSessionHTTPClient(), baseURL: apiURL)

// In tests, swap the real client for a spy
let (sut, spy) = (RemoteArtistSearchLoader(client: HTTPClientSpy(), baseURL: anyURL()), spy)
```

This means every unit test runs in complete isolation with no network calls.

---

## What was tested and why

**Phase 2 — Remote API layer (21 tests)**
- `RemoteArtistSearchLoader` (9 tests): init side-effects, URL construction, connectivity error, non-200 responses, invalid JSON, empty list, items mapping, memory safety
- `RemoteArtistDetailLoader` (8 tests): same contract for artist detail endpoint
- `RemoteArtistReleasesLoader` (9 tests): same contract for releases endpoint
- `URLSessionHTTPClient` (3 tests): correct URL/method, error delivery, data+response delivery — driven with `URLProtocol` stubs, no URLSession subclassing

All tests use **Swift Testing** (`import Testing`) and run on macOS with no simulator.

---

## Observability and security choices

- **No token in source**: The Discogs API token lives in `Configuration/Secrets.xcconfig`, which is gitignored. A `.template` file is committed instead.
- **Ephemeral session in E2E tests**: Prevents stale cache from masking real API behaviour.
- **Thread Sanitizer**: Enabled on CI for the domain test scheme.

---

## What I would improve or add next

- Phase 3: Local cache layer with CoreData (offline support, 7-day max-age policy)
- Phase 4: UI prototype with hardcoded data to nail the design
- Phase 5: Production SwiftUI views + `@Observable` ViewModels, tested in isolation
- Phase 6: Composition Root wiring all layers together in the app target
- CI: add `DISCOGS_API_TOKEN` as a GitHub Actions secret to enable E2E tests on every push
