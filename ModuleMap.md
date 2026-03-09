# Module Map — DiscogsSearch

## Module Boundaries

### `DiscogsSearch` — macOS Framework (Domain + Infrastructure)
- All domain models (`ArtistSearchResult`, `Artist`, `Member`, `Release`, `Page<T>`)
- All public protocols (`HTTPClient`, loader protocols)
- All `Remote*Loader` implementations and mappers
- All `@Observable` ViewModels
- **No UIKit, no SwiftUI, no AppKit imports allowed here**
- Tests run on macOS — no simulator required

### `DiscogsSearch` — iOS App Target
- SwiftUI `View` types
- `URLSessionHTTPClient` concrete implementation
- Composition Root (wires everything together)
- `Secrets.xcconfig` consumer (reads API token at launch)

### `DiscogsSearchTests` — macOS Unit Test Bundle
- Tests against the macOS framework
- Runs natively on Mac — no simulator, no boot time
- Swift Testing (`import Testing`)

### `DiscogsSearchAPIEndToEndTests` — macOS Test Bundle (Phase 2.4)
- Hits the real Discogs API with a real token
- Validates JSON mapping end-to-end

---

## Dependency Directions

```
┌─────────────────────────────────────┐
│         iOS App Target              │
│  (SwiftUI Views + Composition Root) │
│   URLSessionHTTPClient              │
└────────────┬────────────────────────┘
             │ depends on (protocols only)
             ▼
┌─────────────────────────────────────┐
│   DiscogsSearch macOS Framework     │
│                                     │
│  Protocols                          │
│  ├── HTTPClient                     │
│  ├── ArtistSearchLoader             │
│  ├── ArtistDetailLoader             │
│  └── ArtistReleasesLoader           │
│                                     │
│  Domain Models                      │
│  ├── ArtistSearchResult             │
│  ├── Artist, Member                 │
│  ├── Release                        │
│  └── Page<T>                        │
│                                     │
│  Remote Loaders (implement protos)  │
│  ├── RemoteArtistSearchLoader       │
│  ├── RemoteArtistDetailLoader       │
│  └── RemoteArtistReleasesLoader     │
│                                     │
│  Mappers (private, static)          │
│  ├── ArtistSearchMapper             │
│  ├── ArtistDetailMapper             │
│  └── ArtistReleasesMapper           │
│                                     │
│  ViewModels (@Observable)           │
│  ├── SearchViewModel                │
│  ├── ArtistDetailViewModel          │
│  └── ReleasesViewModel              │
└─────────────────────────────────────┘
             ▲
             │ tests
┌────────────┴────────────────────────┐
│    DiscogsSearchTests               │
│    (macOS Unit Test Bundle)         │
└─────────────────────────────────────┘
```

**Rule:** Arrows point toward the domain framework. No arrow ever points outward from it.

---

## Protocol Contracts

### `HTTPClient`
```swift
public protocol HTTPClient {
    func get(from url: URL, headers: [String: String]) async throws -> (Data, HTTPURLResponse)
}
```

### `ArtistSearchLoader`
```swift
public protocol ArtistSearchLoader {
    func load(query: String, page: Int) async throws -> Page<ArtistSearchResult>
}
```

### `ArtistDetailLoader`
```swift
public protocol ArtistDetailLoader {
    func load(artistID: Int) async throws -> Artist
}
```

### `ArtistReleasesLoader`
```swift
public protocol ArtistReleasesLoader {
    func load(artistID: Int, page: Int) async throws -> Page<Release>
}
```

---

## API Base URL

```
https://api.discogs.com
```

Endpoints used:
- `GET /database/search?q={query}&type=artist&page={page}&per_page=30`
- `GET /artists/{id}`
- `GET /artists/{id}/releases?page={page}&per_page=30&sort=year&sort_order=desc`

---

## Secrets & Configuration

> ⚠️ **Setup required before running the app or end-to-end tests.**

Authentication uses the `Authorization` header:
```
Authorization: Discogs token=YOUR_TOKEN_HERE
```

The token is read from `Secrets.xcconfig`, which is **gitignored** and must be created manually.

See `DeveloperSetup.md` for step-by-step instructions.

---

## What is Deferred (not in scope for this deliverable)

- Local cache / offline support (Phase 3 skipped)
- CoreData or Codable persistence
- Image prefetching with cancellation (NSCache in UI layer is sufficient)
