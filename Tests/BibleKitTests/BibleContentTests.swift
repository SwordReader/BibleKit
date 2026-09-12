import Testing
@testable import BibleKit

@Test func descriptorKeepsProviderScopedIdentityAndCapabilities() {
    let descriptor = BibleContentDescriptor(
        providerID: BibleContentProviderID(rawValue: "crosswire"),
        contentID: BibleContentID(rawValue: "WEB"),
        title: "World English Bible",
        languageCode: "en",
        kind: .bible,
        license: BibleContentLicense(attribution: "Public domain", requiresAttribution: false),
        capabilities: [.read, .search, .download, .offlineReading]
    )

    #expect(descriptor.id == "crosswire:WEB")
    #expect(descriptor.capabilities.contains(.search))
    #expect(!descriptor.capabilities.contains(.export))
}
