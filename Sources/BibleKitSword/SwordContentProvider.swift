import BibleKit
import SwordKit

/// A BibleKit provider that exposes modules installed through SwordKit.
///
/// This adapter is an optional product so the BibleKit core remains independent
/// of the SWORD engine. Applications using this adapter must comply with the
/// licensing terms of SwordKit, SWORD, and each installed module.
public final class SwordContentProvider: BibleContentProvider, @unchecked Sendable {
    public let id: BibleContentProviderID
    private let library: SwordLibrary

    /// Creates a provider backed by an existing SwordKit library.
    public init(
        library: SwordLibrary,
        id: BibleContentProviderID = BibleContentProviderID(rawValue: "sword")
    ) {
        self.library = library
        self.id = id
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
        case .other: .generalBook
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
