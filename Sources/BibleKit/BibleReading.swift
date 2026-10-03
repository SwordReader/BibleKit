/// A reading location interpreted within a particular provider's content.
/// Scripture references retain the provider's native versification; keyed
/// entries retain their native hierarchy. Neither is converted to a global key.
public enum BibleReadingLocation: Hashable, Codable, Sendable {
    case verse(String)
    case keyedEntry(String)
}

/// Rendered content with its resolved location and publisher attribution.
public struct BibleReadingContent: Hashable, Sendable {
    public let providerID: BibleContentProviderID
    public let contentID: BibleContentID
    public let location: BibleReadingLocation
    public let text: String
    /// Provider-produced markup. Hosts must sanitize it before using a web view
    /// and must not assume external scripts or network resources are trusted.
    public let html: String
    public let license: BibleContentLicense

    public init(
        providerID: BibleContentProviderID,
        contentID: BibleContentID,
        location: BibleReadingLocation,
        text: String,
        html: String,
        license: BibleContentLicense
    ) {
        self.providerID = providerID
        self.contentID = contentID
        self.location = location
        self.text = text
        self.html = html
        self.license = license
    }
}

/// Optional reading support, separate from providers that only expose catalogs.
public protocol BibleReadingProvider: BibleContentProvider {
    /// Reads one entry. The content ID is scoped to this provider instance.
    /// Implementations return the resolved location and cooperate with cancellation.
    func read(contentID: BibleContentID, at location: BibleReadingLocation) async throws -> BibleReadingContent
}

/// Common lookup errors. Providers may also throw their own transport/engine errors.
public enum BibleReadingError: Error, Equatable, Sendable {
    case contentNotFound(BibleContentID)
    case unsupportedLocation(BibleReadingLocation)
}
