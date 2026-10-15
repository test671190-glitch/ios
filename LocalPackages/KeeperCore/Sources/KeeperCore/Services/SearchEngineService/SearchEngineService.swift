import Foundation

public protocol SearchEngineServiceProtocol {
    func loadSuggestions(searchText: String, searchEngine: SearchEngine) async throws -> [String]
    func composeSearchURL(input: String, searchEngine: SearchEngine) -> URL?

    typealias SearchEngineTitle = (title: String?, url: URL)
    func parseMetaFrom(url: URL) async -> SearchEngineTitle?
}

final class SearchEngineService: SearchEngineServiceProtocol {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func loadSuggestions(searchText _: String, searchEngine _: SearchEngine) async throws -> [String] {
        // Demo mode: search suggestion servers are cut out.
        []
    }

    func composeSearchURL(input _: String, searchEngine _: SearchEngine) -> URL? {
        // Demo mode: search engine links are cut out.
        nil
    }

    @MainActor
    func parseMetaFrom(url: URL) async -> SearchEngineTitle? {
        // Demo mode: page metadata is not fetched from the network.
        (nil, url)
    }
}
