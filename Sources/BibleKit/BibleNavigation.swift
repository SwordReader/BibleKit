import Foundation

/// A book in the provider's own canon and versification.
public struct BibleBookDescriptor: Hashable, Sendable, Identifiable {
    public enum Testament: String, Codable, Sendable { case old, new }
    public let id: String
    public let name: String
    public let abbreviation: String
    public let chapterCount: Int
    public let testament: Testament
    public init(id: String, name: String, abbreviation: String, chapterCount: Int, testament: Testament) {
        self.id = id; self.name = name; self.abbreviation = abbreviation
        self.chapterCount = chapterCount; self.testament = testament
    }
}

/// Study annotations preserved independently of the native engine.
public struct BibleStudyAnnotation: Hashable, Sendable, Identifiable {
    public enum Kind: String, Sendable { case heading, footnote, crossReference }
    public let id: String
    public let kind: Kind
    public let text: String
    public let references: [String]
    public let type: String?
    public init(id: String, kind: Kind, text: String, references: [String] = [], type: String? = nil) {
        self.id = id; self.kind = kind; self.text = text; self.references = references; self.type = type
    }
}

/// A verse including attributed text and its study annotations.
public struct BibleScriptureVerse: Hashable, Sendable {
    public let reference: String
    public let text: String
    public let content: AttributedString
    public let annotations: [BibleStudyAnnotation]
    public init(reference: String, text: String, content: AttributedString, annotations: [BibleStudyAnnotation] = []) {
        self.reference = reference; self.text = text; self.content = content; self.annotations = annotations
    }
}

/// A complete chapter in the provider's native reading order.
public struct BibleScriptureChapter: Hashable, Sendable {
    public let reference: String
    public let contentID: BibleContentID
    public let verses: [BibleScriptureVerse]
    public init(reference: String, contentID: BibleContentID, verses: [BibleScriptureVerse]) {
        self.reference = reference; self.contentID = contentID; self.verses = verses
    }
}

public protocol BibleNavigationProvider: BibleReadingProvider {
    func books(contentID: BibleContentID) async throws -> [BibleBookDescriptor]
    func entryKeys(contentID: BibleContentID) async throws -> [String]
    func chapter(contentID: BibleContentID, reference: String) async throws -> BibleScriptureChapter
}

/// Moves within the entry order supplied by a provider without interpreting keys.
public enum BibleEntryNavigation {
    public static func adjacentKey(to key: String, offset: Int, in keys: [String]) -> String? {
        guard let index = keys.firstIndex(of: key) else { return nil }
        let (destination, overflow) = index.addingReportingOverflow(offset)
        guard !overflow, keys.indices.contains(destination) else { return nil }
        return keys[destination]
    }
}

public enum BibleSearchMode: String, CaseIterable, Sendable { case phrase, allWords, regularExpression, strongs, morphology }
public struct BibleContentSearchResult: Hashable, Sendable {
    public let contentID: BibleContentID
    public let reference: String
    public let text: String
    public let score: Int
    public init(contentID: BibleContentID, reference: String, text: String, score: Int) {
        self.contentID = contentID; self.reference = reference; self.text = text; self.score = score
    }
}
public protocol BibleSearchProvider: BibleContentProvider {
    func search(contentID: BibleContentID, query: String, mode: BibleSearchMode, scope: String?, progress: @escaping @Sendable (Int) -> Void) async throws -> [BibleContentSearchResult]
}
