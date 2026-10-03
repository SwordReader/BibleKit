import Foundation

/// Versioned JSON format for publisher-authorized or custom reading feeds.
/// Content licenses describe permissions; they do not themselves grant rights.
public struct BibleJSONFeed: Codable, Sendable {
    public let schemaVersion: Int
    public let providerID: BibleContentProviderID
    public let contents: [BibleContentDescriptor]
    public let entries: [BibleFeedEntry]
    public init(schemaVersion: Int = 1, providerID: BibleContentProviderID,
                contents: [BibleContentDescriptor], entries: [BibleFeedEntry]) {
        self.schemaVersion = schemaVersion; self.providerID = providerID
        self.contents = contents; self.entries = entries
    }
}

public struct BibleFeedEntry: Codable, Hashable, Sendable {
    public let contentID: BibleContentID
    public let location: BibleReadingLocation
    public let text: String
    public let html: String
    public init(contentID: BibleContentID, location: BibleReadingLocation, text: String, html: String = "") {
        self.contentID = contentID; self.location = location; self.text = text; self.html = html
    }
}

public enum BibleFeedError: Error, Equatable, Sendable {
    case unsupportedSchema(Int)
    case invalidMetadata
    case duplicateContent
    case duplicateEntry
    case invalidEndpoint
    case invalidResponse
    case responseTooLarge
    case entryNotFound
    case readingNotPermitted
}

/// A read-only snapshot. No downloads, exports, disk cache, or login state are
/// implemented by this provider, regardless of capabilities declared in a feed.
public struct BibleFeedProvider: BibleReadingProvider {
    public let id: BibleContentProviderID
    private let feed: BibleJSONFeed

    public init(feed: BibleJSONFeed) throws {
        guard feed.schemaVersion == 1 else { throw BibleFeedError.unsupportedSchema(feed.schemaVersion) }
        guard !feed.providerID.rawValue.isEmpty else { throw BibleFeedError.invalidMetadata }
        var contentIDs = Set<BibleContentID>()
        for content in feed.contents {
            guard content.providerID == feed.providerID, !content.contentID.rawValue.isEmpty,
                  !content.title.isEmpty, !content.languageCode.isEmpty,
                  !content.license.attribution.isEmpty else { throw BibleFeedError.invalidMetadata }
            guard contentIDs.insert(content.contentID).inserted else { throw BibleFeedError.duplicateContent }
        }
        var entries = Set<EntryID>()
        for entry in feed.entries {
            guard contentIDs.contains(entry.contentID) else { throw BibleFeedError.invalidMetadata }
            guard entries.insert(EntryID(contentID: entry.contentID, location: entry.location)).inserted else {
                throw BibleFeedError.duplicateEntry
            }
        }
        self.id = feed.providerID; self.feed = feed
    }

    public func catalog() async throws -> [BibleContentDescriptor] {
        try Task.checkCancellation()
        return feed.contents.map { item in
            BibleContentDescriptor(providerID: item.providerID, contentID: item.contentID,
                title: item.title, languageCode: item.languageCode, kind: item.kind, version: item.version,
                license: item.license, capabilities: item.capabilities.intersection(.read))
        }
    }

    public func read(contentID: BibleContentID, at location: BibleReadingLocation) async throws -> BibleReadingContent {
        try Task.checkCancellation()
        guard let descriptor = feed.contents.first(where: { $0.contentID == contentID }) else {
            throw BibleReadingError.contentNotFound(contentID)
        }
        guard descriptor.capabilities.contains(.read) else { throw BibleFeedError.readingNotPermitted }
        guard let entry = feed.entries.first(where: { $0.contentID == contentID && $0.location == location }) else {
            throw BibleFeedError.entryNotFound
        }
        return BibleReadingContent(providerID: id, contentID: contentID, location: entry.location,
                                   text: entry.text, html: entry.html, license: descriptor.license)
    }

    /// Returns this snapshot's entry order for a content item.
    public func locations(contentID: BibleContentID) async throws -> [BibleReadingLocation] {
        try Task.checkCancellation()
        guard feed.contents.contains(where: { $0.contentID == contentID }) else {
            throw BibleReadingError.contentNotFound(contentID)
        }
        return feed.entries.filter { $0.contentID == contentID }.map(\.location)
    }

    /// Fetches explicitly requested HTTPS JSON without cookies, credentials,
    /// redirects, or persistent URL caching. Publishers needing authentication
    /// can supply decoded snapshots through `init(feed:)` from their own client.
    public static func load(from url: URL, maximumBytes: Int = 2_000_000) async throws -> Self {
        guard url.scheme?.lowercased() == "https", url.host != nil,
              url.user == nil, url.password == nil, maximumBytes > 0 else { throw BibleFeedError.invalidEndpoint }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpShouldSetCookies = false
        configuration.urlCache = nil
        configuration.urlCredentialStorage = nil
        let session = URLSession(configuration: configuration, delegate: NoFeedRedirects(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (bytes, response) = try await session.bytes(for: request)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode),
              response.mimeType == "application/json" else { throw BibleFeedError.invalidResponse }
        guard response.expectedContentLength <= maximumBytes else { throw BibleFeedError.responseTooLarge }
        var data = Data()
        for try await byte in bytes {
            try Task.checkCancellation()
            guard data.count < maximumBytes else { throw BibleFeedError.responseTooLarge }
            data.append(byte)
        }
        return try Self(feed: JSONDecoder().decode(BibleJSONFeed.self, from: data))
    }

    private struct EntryID: Hashable { let contentID: BibleContentID; let location: BibleReadingLocation }
}

private final class NoFeedRedirects: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
                    completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
