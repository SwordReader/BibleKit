import Foundation
import BibleKit
import BibleKitSword
import SwordKit
import Testing

/// Opt-in integration coverage; module text is never bundled with the tests.
@Suite(.enabled(if: ProcessInfo.processInfo.environment["BIBLEKIT_TEST_MODULE_DIRECTORY"] != nil))
struct RealModuleTests {
    @Test func preservesNativeReadingNavigationAndSearch() async throws {
        let path = try #require(ProcessInfo.processInfo.environment["BIBLEKIT_TEST_MODULE_DIRECTORY"])
        let library = try SwordLibrary(directory: URL(fileURLWithPath: path))
        let module = try #require(library.module(named: "ASV"))
        let provider = SwordContentProvider(library: library)
        let id = BibleContentID(rawValue: "ASV")
        let nativeVerse = try module.verse("John 3:16")
        let reading = try await provider.read(contentID: id, at: .verse("John 3:16"))
        #expect(reading.text == nativeVerse.text)
        #expect(reading.location == .verse(nativeVerse.reference.value))
        #expect(reading.html == (try module.html(nativeVerse.reference.value)))
        let books = try await provider.books(contentID: id)
        #expect(books.count == 66)
        #expect(books.contains { $0.id == "John" && $0.chapterCount == 21 })
        let chapter = try await provider.chapter(contentID: id, reference: "John 3")
        let nativeChapter = try module.chapter("John 3")
        #expect(chapter.verses.map(\.text) == nativeChapter.verses.map(\.text))
        #expect(chapter.verses.count == 36)
        let results = try await provider.search(contentID: id, query: "grace", mode: .phrase, scope: "John", progress: { _ in })
        let nativeResults = try await module.searchAsync("grace", type: .phrase, caseSensitive: false, scope: "John", progress: { _ in }).rankedByRelevance()
        #expect(!results.isEmpty)
        #expect(results.map(\.reference) == nativeResults.map { $0.reference.value })
        #expect(results.map(\.text) == nativeResults.map(\.text))
    }
}
