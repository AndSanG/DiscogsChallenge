# Developer Setup — DiscogsSearch

## Prerequisites

- Xcode 16+
- A Discogs account with a personal access token
  - Go to: https://www.discogs.com/settings/developers
  - Click **Generate new token**
  - Copy the token value

---

## ⚠️ Required: Create Secrets.xcconfig

The app reads the Discogs API token from a configuration file that is **not committed to git**.

1. In the project root (next to `DiscogsSearch.xcodeproj`), create the file:

   ```
   DiscogsSearch/Configuration/Secrets.xcconfig
   ```

2. Add the following line, replacing the placeholder with your actual token:

   ```
   DISCOGS_API_TOKEN = your_personal_access_token_here
   ```

3. The file is already listed in `.gitignore` — do not remove that entry.

> The app will crash at launch with a fatal error if this file is missing or the token is empty.
> The end-to-end test target (`DiscogsSearchAPIEndToEndTests`) also requires this file.

---

## Running the Project

1. Complete the Secrets step above.
2. Open `DiscogsSearch.xcodeproj`.
3. Select the `DiscogsSearch` scheme.
4. Build and run on an iPhone simulator (iOS 17+).

## Running Tests

| Test target | How to run | Requires simulator? |
|---|---|---|
| `DiscogsSearchTests` | Cmd+U or `xcodebuild test -scheme DiscogsSearchTests` | No — runs on Mac |
| `DiscogsSearchAPIEndToEndTests` | Run separately — requires network + valid token | No — runs on Mac |

---

## Static Analysis (SwiftLint)

SwiftLint is integrated via Swift Package Manager and runs as a build phase.

- To run manually: `swiftlint lint` from the project root
- Configuration: `.swiftlint.yml` in the project root
- Violations are shown as Xcode warnings/errors in the Issue Navigator

---

## Architecture Overview

See `ModuleMap.md` for the full dependency diagram and protocol contracts.

The app uses **MVVM + Clean Architecture**:
- Domain models and protocols live in a macOS framework target (no UIKit/SwiftUI)
- Remote loaders implement the protocols and live in the same framework
- ViewModels use `@Observable` (iOS 17+) and live in the framework (no UI deps)
- SwiftUI views and the composition root live exclusively in the iOS app target
- `URLSessionHTTPClient` is the only concrete HTTP implementation, created in the composition root
