import Foundation
@testable import DiscogsSearch

final class HTTPClientSpy: HTTPClient, @unchecked Sendable {
    struct Request: Equatable {
        let url: URL
        let headers: [String: String]
    }

    private(set) var requests = [Request]()
    private var queuedResults = [Result<(Data, HTTPURLResponse), Error>]()

    func stub(_ result: Result<(Data, HTTPURLResponse), Error>) {
        queuedResults.append(result)
    }

    func get(from url: URL, headers: [String: String]) async throws -> (Data, HTTPURLResponse) {
        requests.append(Request(url: url, headers: headers))
        return try queuedResults.removeFirst().get()
    }
}
