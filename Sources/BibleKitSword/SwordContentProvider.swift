import BibleKit
import SwordKit

/// A BibleKit provider that exposes modules installed through SwordKit.
///
/// This adapter is an optional product so the BibleKit core remains independent
/// of the SWORD engine. Applications using this adapter must comply with the
/// licensing terms of SwordKit, SWORD, and each installed module.
public final class SwordContentProvider: BibleReadingProvider, Sendable {
    public let id: BibleContentProviderID
    let library: SwordLibrary
    let installer: SwordModuleInstaller?

    /// Creates a provider backed by an existing SwordKit library.
    public init(
        library: SwordLibrary,
        id: BibleContentProviderID = BibleContentProviderID(rawValue: "sword"),
        installer: SwordModuleInstaller? = nil
    ) {
        self.library = library
        self.id = id
        self.installer = installer
    }

    /// Returns metadata for modules currently installed in the SWORD library.
    public func catalog() async throws -> [BibleContentDescriptor] {
        library.modules.map { module in
            Self.descriptor(
                providerID: id,
                moduleName: module.name,
                title: module.title,
                language: module.language,
                category: module.category,
                version: module.version,
                copyright: module.copyright
            )
        }
    }

    /// Reads a Bible verse or a module-native dictionary, book, or devotional entry.
    public func read(contentID: BibleContentID, at location: BibleReadingLocation) async throws -> BibleReadingContent {
        try Task.checkCancellation()
        guard let module = library.module(named: contentID.rawValue) else {
            throw BibleReadingError.contentNotFound(contentID)
        }
        let descriptor = Self.descriptor(
            providerID: id, moduleName: module.name, title: module.title,
            language: module.language, category: module.category,
            version: module.version, copyright: module.copyright
        )
        let task = Task.detached {
            try Task.checkCancellation()
            let resolved: BibleReadingLocation
            let text: String
            let html: String
            switch location {
            case .verse(let reference):
                guard module.category == .bible else {
                    throw BibleReadingError.unsupportedLocation(location)
                }
                let verse = try module.verse(reference)
                resolved = .verse(verse.reference.value)
                text = verse.text
                html = try module.html(verse.reference.value)
            case .keyedEntry(let key):
                guard module.category.supportsKeyedEntries else {
                    throw BibleReadingError.unsupportedLocation(location)
                }
                let entry = try module.keyedEntry(for: key)
                resolved = .keyedEntry(entry.key)
                text = entry.text
                html = entry.html
            }
            try Task.checkCancellation()
            return BibleReadingContent(
                providerID: self.id, contentID: descriptor.contentID,
                location: resolved, text: text, html: html, license: descriptor.license
            )
        }
        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }

    static func descriptor(
        providerID: BibleContentProviderID,
        moduleName: String,
        title: String,
        language: String,
        category: SwordModule.Category,
        version: String?,
        copyright: String?
    ) -> BibleContentDescriptor {
        let attribution = copyright?.trimmingCharacters(in: .whitespacesAndNewlines)
        let requiresAttribution = attribution.map {
            $0.localizedCaseInsensitiveCompare("public domain") != .orderedSame
        } ?? false

        return BibleContentDescriptor(
            providerID: providerID,
            contentID: BibleContentID(rawValue: moduleName),
            title: title,
            languageCode: language,
            kind: contentKind(for: category),
            version: version,
            license: BibleContentLicense(
                attribution: attribution?.isEmpty == false
                    ? attribution!
                    : "License information supplied by the SWORD module",
                requiresAttribution: requiresAttribution
            ),
            capabilities: capabilities(for: category)
        )
    }

    private static func contentKind(for category: SwordModule.Category) -> BibleContentKind {
        switch category {
        case .bible: .bible
        case .commentary: .commentary
        case .dictionary: .dictionary
        case .devotional: .devotional
        case .generalBook: .generalBook
        case .other: .other
        }
    }

    private static func capabilities(for category: SwordModule.Category) -> BibleContentCapabilities {
        switch category {
        case .bible:
            [.read, .search, .offlineReading, .annotations]
        case .dictionary, .devotional, .generalBook:
            [.read, .offlineReading]
        case .commentary, .other:
            [.offlineReading]
        }
    }
}
