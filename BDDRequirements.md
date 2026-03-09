# BDD Requirements — DiscogsSearch

## UC-1: Search Artists

**Given** the user is on the Search screen with no prior query
**Then** an empty state is displayed prompting them to search for an artist

---

**Given** the user types an artist name in the search bar
**When** the debounce period (300 ms) elapses
**Then** the app requests the first page of artist results from the Discogs API (30 items/page)
**And** a loading indicator is visible during the request

---

**Given** a search request completes successfully
**When** the response contains results
**Then** a list is displayed with each artist's thumbnail and name

---

**Given** a search request completes successfully
**When** the response contains no results
**Then** an empty state message is displayed ("No artists found")

---

**Given** a search request fails (network error or non-200 response)
**Then** an error message is displayed and the list is not altered

---

**Given** the user has scrolled to the bottom of the results
**When** more pages are available
**Then** the next page is loaded and appended to the list

---

**Given** the user changes the search query
**When** a previous request is still in-flight
**Then** the previous request is cancelled and a new one is started

---

## UC-2: View Artist Detail

**Given** the user taps an artist in the search results
**When** the detail screen loads
**Then** the artist's name, profile text, and primary image are displayed
**And** a button/link to the artist's releases is available

---

**Given** the artist is a band (has members)
**When** the detail screen loads
**Then** a members section is displayed listing each member's name

---

**Given** the detail request fails
**Then** an error message is displayed

---

## UC-3: Browse Artist Releases

**Given** the user navigates to an artist's releases
**When** the releases load
**Then** they are displayed sorted by year, newest to oldest (30 items/page)
**And** each cell shows the most relevant release info (title, year, label, genre, thumbnail)

---

**Given** releases are loaded
**When** the user applies a filter (by year, genre, or label)
**Then** only releases matching the filter criteria are shown

---

**Given** the user has scrolled to the bottom
**When** more pages are available
**Then** the next page is loaded and appended

---

**Given** a releases request fails
**Then** an error message is displayed and existing items are not cleared

---

## Domain Models

| Model | Properties | Notes |
|---|---|---|
| `ArtistSearchResult` | `id: Int`, `name: String`, `thumbnailURL: URL?` | Lightweight — search list only |
| `Artist` | `id: Int`, `name: String`, `profile: String`, `imageURL: URL?`, `members: [Member]` | Full detail |
| `Member` | `id: Int`, `name: String`, `isActive: Bool` | Embedded in `Artist` |
| `Release` | `id: Int`, `title: String`, `year: Int?`, `genres: [String]`, `labels: [String]`, `thumbnailURL: URL?`, `type: String` | Releases list |
| `Page<T>` | `items: [T]`, `hasNextPage: Bool` | Generic pagination wrapper |

## What is explicitly out of scope

- Offline / local cache (no Phase 3) — noted in "What I'd add next" in README
- User authentication / OAuth
- Writing to the Discogs API (collections, wantlists)
