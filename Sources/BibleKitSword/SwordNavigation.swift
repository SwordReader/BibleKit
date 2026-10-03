import BibleKit
import Foundation
import SwordKit

extension SwordContentProvider: BibleNavigationProvider, BibleSearchProvider {
    public func books(contentID: BibleContentID) async throws -> [BibleBookDescriptor] {
        let module = try installedModule(contentID)
        return try await runNative {
            try module.books().map {
                BibleBookDescriptor(id: $0.osisName, name: $0.name, abbreviation: $0.preferredAbbreviation,
                                    chapterCount: $0.chapterCount, testament: $0.testament == .old ? .old : .new)
            }
        }
    }

    public func entryKeys(contentID: BibleContentID) async throws -> [String] {
        let module = try installedModule(contentID)
        return try await runNative { try module.keyedEntryKeys() }
    }

    public func chapter(contentID: BibleContentID, reference: String) async throws -> BibleScriptureChapter {
        let module = try installedModule(contentID)
        return try await runNative {
            let chapter = try module.chapter(reference)
            let verses = try chapter.verses.map { verse in
                try Task.checkCancellation()
                let annotations = verse.headings.map {
                    BibleStudyAnnotation(id: $0.identifier, kind: .heading, text: $0.body)
                } + verse.footnotes.map {
                    BibleStudyAnnotation(id: $0.identifier, kind: .footnote, text: $0.body, type: $0.type)
                } + verse.crossReferences.map {
                    BibleStudyAnnotation(id: $0.footnoteIdentifier, kind: .crossReference, text: "", references: $0.references.map(\.value))
                }
                return BibleScriptureVerse(reference: verse.reference.value, text: verse.text,
                    content: (try? module.attributedString(verse.reference.value)) ?? AttributedString(verse.text),
                    annotations: annotations)
            }
            return BibleScriptureChapter(reference: chapter.reference.value,
                                         contentID: BibleContentID(rawValue: chapter.moduleName), verses: verses)
        }
    }

    public func search(contentID: BibleContentID, query: String, mode: BibleSearchMode, scope: String?, progress: @escaping @Sendable (Int) -> Void) async throws -> [BibleContentSearchResult] {
        let module = try installedModule(contentID)
        let type: SwordSearchType
        switch mode {
        case .phrase: type = .phrase
        case .allWords: type = .multiWord
        case .regularExpression: type = .regularExpression
        case .strongs: type = .strongs
        case .morphology: type = .morphology
        }
        return try await module.searchAsync(query, type: type, caseSensitive: false, scope: scope, progress: progress)
            .rankedByRelevance().map {
                BibleContentSearchResult(contentID: BibleContentID(rawValue: $0.moduleName), reference: $0.reference.value,
                                         text: $0.text, score: $0.score)
            }
    }

    func installedModule(_ contentID: BibleContentID) throws -> SwordModule {
        try Task.checkCancellation()
        guard let module = library.module(named: contentID.rawValue) else {
            throw BibleReadingError.contentNotFound(contentID)
        }
        return module
    }
}

/// Keeps native engine calls away from UI actors, with cooperative cancellation.
func runNative<T: Sendable>(_ operation: @escaping @Sendable () throws -> T) async throws -> T {
    try Task.checkCancellation()
    let task = Task.detached {
        try Task.checkCancellation()
        let result = try operation()
        try Task.checkCancellation()
        return result
    }
    return try await withTaskCancellationHandler { try await task.value } onCancel: { task.cancel() }
}
