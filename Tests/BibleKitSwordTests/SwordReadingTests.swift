import Foundation
import BibleKit
import BibleKitSword
import SwordKit
import Testing

@Test func missingSwordContentReturnsProviderError() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let provider = SwordContentProvider(library: try SwordLibrary(directory: directory))
    await #expect(throws: BibleReadingError.contentNotFound(BibleContentID(rawValue: "missing"))) {
        try await provider.read(contentID: BibleContentID(rawValue: "missing"), at: .verse("John 3:16"))
    }
}

@Test func cancelledSwordReadStopsBeforeModuleLookup() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let provider = SwordContentProvider(library: try SwordLibrary(directory: directory))
    let task = Task {
        withUnsafeCurrentTask { $0?.cancel() }
        return try await provider.read(contentID: BibleContentID(rawValue: "missing"), at: .verse("John 3:16"))
    }
    await #expect(throws: CancellationError.self) { try await task.value }
}

@Test func moduleManagementRequiresConfiguredInstaller() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let provider = SwordContentProvider(library: try SwordLibrary(directory: directory))
    await #expect(throws: SwordProviderError.self) {
        try await provider.remove(contentID: BibleContentID(rawValue: "missing"))
    }
    #expect(try await provider.localCatalog(at: directory).isEmpty)
    #expect(try await provider.parallelChapter(reference: "John 3", contentIDs: []).isEmpty)
}
