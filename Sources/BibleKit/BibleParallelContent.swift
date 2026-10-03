public struct BibleParallelText: Hashable, Sendable {
    public let contentID: BibleContentID
    public let text: String?
    public init(contentID: BibleContentID, text: String?) { self.contentID = contentID; self.text = text }
}
public struct BibleWordLink: Hashable, Sendable {
    public let strongsNumber: String
    public let words: [String]
    public init(strongsNumber: String, words: [String]) { self.strongsNumber = strongsNumber; self.words = words }
}
public struct BibleParallelRow: Hashable, Sendable {
    public let reference: String
    public let texts: [BibleParallelText]
    public let wordLinks: [BibleWordLink]
    public init(reference: String, texts: [BibleParallelText], wordLinks: [BibleWordLink]) {
        self.reference = reference; self.texts = texts; self.wordLinks = wordLinks
    }
}
public protocol BibleParallelProvider: BibleContentProvider {
    func parallelChapter(reference: String, contentIDs: [BibleContentID]) async throws -> [BibleParallelRow]
}
