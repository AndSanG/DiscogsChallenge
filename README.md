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
       │                         SearchView, ArtistDetailView, ReleasesView (SwiftUI)
       │                         AuthenticatedHTTPClient (app-target decorator)
       ▼
DiscogsSearch (macOS framework)
  ├── Domain
  │    ├── Models:   ArtistSearchResult, Artist, Member, Release, Page<T>
  │    ├── Loaders:  ArtistSearchLoader, ArtistDetailLoader, ArtistReleasesLoader (protocols)
  │    └── ViewModels: SearchViewModel, ArtistDetailViewModel, ReleasesViewModel (@Observable)
  └── Networking
       ├── HTTPClient (protocol)
       ├── URLSessionHTTPClient (concrete)
       ├── RemoteArtistSearchLoader
       ├── RemoteArtistDetailLoader
       ├── RemoteArtistReleasesLoader
       └── Mappers: ArtistSearchMapper, ArtistDetailMapper, ArtistReleasesMapper
```

**Composition Root** (`DiscogsSearchApp.swift`) is the only place that knows about concrete types. It:
1. Reads the API token from `Info.plist` (injected at build time from `Secrets.xcconfig`)
2. Creates a single `URLSessionHTTPClient` wrapped by `AuthenticatedHTTPClient`
3. Injects the shared client into all three `Remote*Loader` instances
4. Creates `SearchViewModel` and passes it to `SearchView` via `@State`
5. Registers `navigationDestination` handlers that create `ArtistDetailViewModel` / `ReleasesViewModel` on demand — the views never know where the data comes from

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

**69 tests total — all run on macOS, no simulator required.**

**Phase 2 — Remote API layer (29 tests)**
- `RemoteArtistSearchLoader` (9 tests): init side-effects, URL construction, connectivity error, non-200 responses, invalid JSON, empty list, items mapping, memory safety
- `RemoteArtistDetailLoader` (8 tests): same contract for artist detail endpoint
- `RemoteArtistReleasesLoader` (9 tests): same contract for releases endpoint
- `URLSessionHTTPClient` (3 tests): correct URL/method, error delivery, data+response delivery — driven with `URLProtocol` stubs, no URLSession subclassing

**Phase 5 — ViewModel layer (40 tests)**
- `SearchViewModel` (12 tests): init side-effects, load triggers loader, `isLoading` during/after request, items delivered on success, error message on failure, error cleared on reload, memory safety, pagination append, no-op on last page, search debounce
- `ArtistDetailViewModel` (9 tests): same loading contract for artist detail
- `ReleasesViewModel` (19 tests): same loading contract + pagination for releases + 8 filter tests (year/genre/label apply, clear, computed available options)

All tests use **Swift Testing** (`import Testing`) with continuation-based spies for precise async timing control.

---

## Observability and security choices

- **No token in source**: The Discogs API token lives in `Configuration/Secrets.xcconfig`, which is gitignored. A `.template` file is committed instead. At runtime the app reads the token from `Info.plist`, where it is injected via a build setting.
- **`AuthenticatedHTTPClient` decorator**: The token is added as an `Authorization: Discogs token=…` header in a single place — the app-target decorator — and is invisible to all loaders and ViewModels.
- **Ephemeral `URLSession`**: Used in both the production app and E2E tests to prevent stale cache from masking real API responses.
- **Thread Sanitizer**: Enabled on CI for the domain test scheme.
- **User-friendly error messages**: All `Remote*Loader.Error` enums conform to `LocalizedError`, so users see "Check your internet connection and try again." rather than raw Swift enum descriptions like `error 0`.
- **Cancellation safety**: `URLSession` throws `URLError(.cancelled)` — not `CancellationError` — when a `Task` is cancelled. All loaders re-map it to `CancellationError`; ViewModels silently discard it. Rapid typing during search never produces false connectivity alerts.

---

## Code quality — SwiftLint

SwiftLint is wired into the `DiscogsSearch` build phase via `project.yml`. The rule set (`.swiftlint.yml`) enables opt-in rules beyond the defaults:

| Rule | Opt-in? | Violations found | Resolution |
|------|---------|-----------------|------------|
| `force_unwrapping` | yes | 3 (URL inits in 2 loaders + app root) | Replaced `!` with `guard`/`preconditionFailure` |
| `nesting` | default | 6 (nested `struct` inside `enum` in all three Mappers) | Moved nested types to enum scope; renamed inner `Label` → `ReleaseLabel` to avoid collision |
| `statement_position` | default | 1 (`catch` on its own line in `RemoteArtistDetailLoader`) | Expanded single-line `do/catch` to multi-line |
| `implicit_return` / `optional_initialization` | yes | 3 (`= nil` on optional vars in two ViewModels) | Dropped explicit `= nil` initialisation |
| `line_length` + `multiline_parameters` | yes | 1 (`Release.init` at 123 chars) | Expanded to one-parameter-per-line |
| `trailing_closure` | yes | 1 (`first(where: { })` in `ArtistDetailMapper`) | Changed to trailing-closure form `first { }` |

After fixes, `swiftlint lint` reports **zero warnings**.

---

## Development process

The project was built with a strict **Red → Green → Refactor → Commit** TDD cycle enforced by a custom runbook:

1. Each new behaviour started as a failing test (`#expect` assertion with no production code).
2. The minimum production code to make it green was written — nothing more.
3. Once green, the test + implementation were committed as a single atomic commit.
4. No phase advanced until every test in that phase had its own commit.

This discipline is visible in the git history: the networking layer (Phase 2) and ViewModel layer (Phase 5) each have one commit per test, making bisecting and code review straightforward.

---

## What I would improve or add next

- **Offline support**: A local cache layer (CoreData store + `LocalArtistSearchLoader`) with a 7-day max-age policy and a `FeedLoaderWithFallbackComposite` that tries the cache first and falls back to the network
- **Image caching**: An `NSCache`-backed `CachedAsyncImage` wrapper to avoid re-fetching thumbnails on scroll
- **Accessibility**: VoiceOver labels on artist thumbnails and release artwork
