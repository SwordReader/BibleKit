import Foundation
import Testing
@testable import BibleKit

private func exampleFeed(entries: [BibleFeedEntry]? = nil, version: Int = 1) -> BibleJSONFeed {
    let id = BibleContentID(rawValue: "daily")
    return BibleJSONFeed(schemaVersion: version, providerID: BibleContentProviderID(rawValue: "publisher"), contents: [
        BibleContentDescriptor(providerID: BibleContentProviderID(rawValue: "publisher"), contentID: id,
            title: "Daily Readings", languageCode: "en", kind: .devotional,
            license: BibleContentLicense(attribution: "Example Publisher"),
            capabilities: [.read, .download, .search, .export])
    ], entries: entries ?? [BibleFeedEntry(contentID: id, location: .keyedEntry("day-1"), text: "Reading")])
}

@Test func feedRoundTripPreservesAttributionAndRestrictsUnsupportedActions() async throws {
    let data = try JSONEncoder().encode(exampleFeed())
    let provider = try BibleFeedProvider(feed: JSONDecoder().decode(BibleJSONFeed.self, from: data))
    let catalog = try await provider.catalog()
    #expect(catalog[0].capabilities == .read)
    let content = try await provider.read(contentID: catalog[0].contentID, at: .keyedEntry("day-1"))
    #expect(content.text == "Reading")
    #expect(content.license.attribution == "Example Publisher")
    await #expect(throws: BibleFeedError.entryNotFound) {
        try await provider.read(contentID: catalog[0].contentID, at: .keyedEntry("missing"))
    }
}

@Test func feedRejectsUnsupportedSchemaAndDuplicateKeys() {
    #expect(throws: BibleFeedError.unsupportedSchema(2)) { try BibleFeedProvider(feed: exampleFeed(version: 2)) }
    let entry = BibleFeedEntry(contentID: BibleContentID(rawValue: "daily"), location: .keyedEntry("day-1"), text: "Reading")
    #expect(throws: BibleFeedError.duplicateEntry) { try BibleFeedProvider(feed: exampleFeed(entries: [entry, entry])) }
}

@Test func feedRejectsInsecureEndpointsBeforeNetworkAccess() async {
    await #expect(throws: BibleFeedError.invalidEndpoint) {
        try await BibleFeedProvider.load(from: URL(string: "http://example.com/feed.json")!)
    }
    await #expect(throws: BibleFeedError.invalidEndpoint) {
        try await BibleFeedProvider.load(from: URL(string: "https://user:password@example.com/feed.json")!)
    }
}
