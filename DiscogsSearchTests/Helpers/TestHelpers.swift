import Foundation
@testable import DiscogsSearch

func anyURL() -> URL { URL(string: "https://any-url.com")! }
func anyData() -> Data { Data("any data".utf8) }
func anyError() -> NSError { NSError(domain: "test", code: 0) }

func makeResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func makeSearchJSON(_ items: [[String: Any]] = [], page: Int = 1, pages: Int = 1) -> Data {
    let json: [String: Any] = [
        "results": items,
        "pagination": ["page": page, "pages": pages, "per_page": 30, "items": items.count]
    ]
    return try! JSONSerialization.data(withJSONObject: json)
}

func makeSearchItem(id: Int, name: String, thumb: String) -> [String: Any] {
    ["id": id, "title": name, "thumb": thumb, "type": "artist"]
}

/// Suspends briefly so an enqueued `@MainActor` Task has time to start and
/// reach its first suspension point (e.g. an async spy call).
func waitForTaskToStart() async {
    try? await Task.sleep(for: .milliseconds(10))
}
