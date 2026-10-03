import Foundation

/// A stable identifier for the provider that owns a piece of Bible content.
public struct BibleContentProviderID: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A provider-scoped stable identifier for a content item.
public struct BibleContentID: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// The broad reading experience a content item represents.
public enum BibleContentKind: String, CaseIterable, Codable, Sendable {
    case bible
    case commentary
    case dictionary
    case devotional
    case generalBook
    case readingPlan
    case other
}

/// Actions that a provider permits for a content item.
public struct BibleContentCapabilities: OptionSet, Hashable, Codable, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let read = Self(rawValue: 1 << 0)
    public static let search = Self(rawValue: 1 << 1)
    public static let download = Self(rawValue: 1 << 2)
    public static let offlineReading = Self(rawValue: 1 << 3)
    public static let annotations = Self(rawValue: 1 << 4)
    public static let export = Self(rawValue: 1 << 5)
}

/// Attribution and usage terms that must travel with provider content.
public struct BibleContentLicense: Hashable, Codable, Sendable {
    public let attribution: String
    public let termsURL: URL?
    public let requiresAttribution: Bool

    public init(attribution: String, termsURL: URL? = nil, requiresAttribution: Bool = true) {
        self.attribution = attribution
        self.termsURL = termsURL
        self.requiresAttribution = requiresAttribution
    }
}

/// Provider-owned metadata suitable for a content catalog.
public struct BibleContentDescriptor: Hashable, Codable, Sendable, Identifiable {
    public let providerID: BibleContentProviderID
    public let contentID: BibleContentID
    public let title: String
    public let languageCode: String
    public let kind: BibleContentKind
    public let version: String?
    public let license: BibleContentLicense
    public let capabilities: BibleContentCapabilities

    public var id: String { "\(providerID.rawValue):\(contentID.rawValue)" }

    public init(
        providerID: BibleContentProviderID,
        contentID: BibleContentID,
        title: String,
        languageCode: String,
        kind: BibleContentKind,
        version: String? = nil,
        license: BibleContentLicense,
        capabilities: BibleContentCapabilities
    ) {
        self.providerID = providerID
        self.contentID = contentID
        self.title = title
        self.languageCode = languageCode
        self.kind = kind
        self.version = version
        self.license = license
        self.capabilities = capabilities
    }
}

/// A source of Bible and study content, such as a local SWORD library or an authorized feed.
public protocol BibleContentProvider: Sendable {
    var id: BibleContentProviderID { get }
    func catalog() async throws -> [BibleContentDescriptor]
}
