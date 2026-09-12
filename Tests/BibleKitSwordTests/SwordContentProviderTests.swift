import BibleKit
@testable import BibleKitSword
import SwordKit
import Testing

@Test func mapsInstalledSwordBibleMetadataToBibleKit() {
    let descriptor = SwordContentProvider.descriptor(
        providerID: BibleContentProviderID(rawValue: "sword"),
        moduleName: "WEB",
        title: "World English Bible",
        language: "en",
        category: .bible,
        version: "1.0",
        copyright: "Public domain"
    )

    #expect(descriptor.id == "sword:WEB")
    #expect(descriptor.kind == .bible)
    #expect(descriptor.capabilities.contains(.search))
    #expect(descriptor.capabilities.contains(.offlineReading))
    #expect(!descriptor.license.requiresAttribution)
}

@Test func mapsSwordGeneralBooksAsKeyedContent() {
    let descriptor = SwordContentProvider.descriptor(
        providerID: BibleContentProviderID(rawValue: "sword"),
        moduleName: "ExampleBook",
        title: "Example Book",
        language: "en",
        category: .generalBook,
        version: nil,
        copyright: "Example Publisher"
    )

    #expect(descriptor.kind == .generalBook)
    #expect(descriptor.capabilities.contains(.read))
    #expect(!descriptor.capabilities.contains(.search))
    #expect(descriptor.license.requiresAttribution)
}
