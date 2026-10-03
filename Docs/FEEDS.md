# Custom and authorized JSON feeds

`BibleJSONFeed` schema version 1 represents a read-only catalog and its entries.
Create a feed using Swift's `JSONEncoder` and publish the JSON over HTTPS with
`Content-Type: application/json`. The matching `JSONDecoder` is the format's
reference decoder; provider and content identifiers are Codable raw-value types.

Each descriptor includes a provider ID, content ID, title, language, kind,
license attribution, and capability bitset. Entries contain their content ID,
typed verse/keyed-entry location, text, and optional XHTML. Duplicate content or
locations, mismatched provider IDs, and unsupported schema versions are rejected.

`BibleFeedProvider.load(from:)` requests the URL only when explicitly invoked.
It permits HTTPS, rejects embedded credentials and redirects, caps JSON input at
2 MB by default, and uses an ephemeral session without cookies or disk caching.
It supports reading the snapshot, rather than download/search/export actions.

Publishers with authenticated APIs can implement `BibleReadingProvider` or pass
an authorized decoded snapshot to `BibleFeedProvider(feed:)`. The framework
stores no publisher secrets and supplies no proprietary translation text. Feed
metadata describes usage terms; it does not grant a license to content.

Apps must sanitize provider XHTML before rendering it in a web view. They should
display attribution with reading results and follow the publisher's storage and
redistribution terms. Persistent caching and provider-specific entitlements
remain separately negotiated integrations.
