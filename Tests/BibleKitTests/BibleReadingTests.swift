import Foundation
import Testing
@testable import BibleKit

@Test func readingLocationPreservesReferenceKindThroughCoding() throws {
    let locations: [BibleReadingLocation] = [.verse("John 3:16"), .keyedEntry("/Book/Chapter III")]
    let data = try JSONEncoder().encode(locations)
    #expect(try JSONDecoder().decode([BibleReadingLocation].self, from: data) == locations)
}

@Test func readingProviderKeepsResolvedLocationAndAttribution() async throws {
    let provider: any BibleReadingProvider = ExampleReadingProvider()
    let content = try await provider.read(
        contentID: BibleContentID(rawValue: "daily"),
        at: .keyedEntry("today")
    )
    #expect(content.location == .keyedEntry("10.03"))
    #expect(content.html == "<p>Daily reading</p>")
    #expect(content.license.attribution == "Example Publisher")
    #expect(content.providerID == provider.id)
}

private struct ExampleReadingProvider: BibleReadingProvider {
    let id = BibleContentProviderID(rawValue: "example")
    func catalog() async throws -> [BibleContentDescriptor] { [] }
    func read(contentID: BibleContentID, at location: BibleReadingLocation) async throws -> BibleReadingContent {
        BibleReadingContent(
            providerID: id, contentID: contentID, location: .keyedEntry("10.03"),
            text: "Daily reading", html: "<p>Daily reading</p>",
            license: BibleContentLicense(attribution: "Example Publisher")
        )
    }
}
