import BibleKit
import Foundation
import SwordKit

public enum SwordProviderError: Error, Sendable { case installerNotConfigured }

extension SwordContentProvider: BibleParallelProvider {
    public func refresh() async throws {
        try await runNative { self.library.refresh() }
    }

    /// Installs a user-selected archive, such as a paired Watch transfer.
    public func install(contentID: BibleContentID, fromArchive archive: URL) async throws {
        guard let installer else { throw SwordProviderError.installerNotConfigured }
        try await runNative {
            try installer.install(moduleNamed: contentID.rawValue, fromArchive: archive)
            self.library.refresh()
        }
    }
    /// Inspects a local catalog without installing content.
    public func localCatalog(at directory: URL) async throws -> [BibleContentDescriptor] {
        try await runNative {
            try SwordModuleCatalog(directory: directory).modules.map { self.catalogDescriptor($0) }
        }
    }

    /// Installs from an explicitly selected local catalog and refreshes the library.
    public func install(contentID: BibleContentID, from directory: URL) async throws {
        guard let installer else { throw SwordProviderError.installerNotConfigured }
        try await runNative {
            try installer.install(moduleNamed: contentID.rawValue, from: SwordModuleCatalog(directory: directory))
            self.library.refresh()
        }
    }

    public func remoteCatalog(from repository: SwordModuleRepository, acknowledgingRemoteAccessRisks: Bool) async throws -> [BibleContentDescriptor] {
        guard let installer else { throw SwordProviderError.installerNotConfigured }
        return try await installer.refreshCatalog(for: repository, acknowledgingRemoteAccessRisks: acknowledgingRemoteAccessRisks)
            .modules.map { catalogDescriptor($0) }
    }

    public func install(contentID: BibleContentID, from repository: SwordModuleRepository,
                        acknowledgingRemoteAccessRisks: Bool,
                        progress: @escaping @Sendable (SwordTransferProgress) -> Void) async throws {
        guard let installer else { throw SwordProviderError.installerNotConfigured }
        try await installer.install(moduleNamed: contentID.rawValue, from: repository,
                                    acknowledgingRemoteAccessRisks: acknowledgingRemoteAccessRisks, progress: progress)
        library.refresh()
    }

    public func remove(contentID: BibleContentID) async throws {
        guard let installer else { throw SwordProviderError.installerNotConfigured }
        try await runNative {
            try installer.remove(moduleNamed: contentID.rawValue)
            self.library.refresh()
        }
    }

    public func parallelChapter(reference: String, contentIDs: [BibleContentID]) async throws -> [BibleParallelRow] {
        guard let first = contentIDs.first else { return [] }
        let module = try installedModule(first)
        let range: String? = try await runNative {
            let chapter = try module.chapter(reference)
            guard let firstVerse = chapter.verses.first?.reference.value,
                  let last = chapter.verses.last?.reference.value,
                  let endingVerse = last.split(separator: ":").last else { return nil }
            return "\(firstVerse)-\(endingVerse)"
        }
        guard let range else { return [] }
        return try await library.parallelPassageAsync(range, modules: contentIDs.map(\.rawValue))
            .alignedVerses.map { row in
                BibleParallelRow(reference: row.reference.value,
                    texts: contentIDs.map { BibleParallelText(contentID: $0, text: row.versesByModule[$0.rawValue]?.text) },
                    wordLinks: row.comparison.wordLinks.map {
                        BibleWordLink(strongsNumber: $0.strongsNumber,
                                      words: $0.locations.map { "\($0.moduleName): \($0.token.text)" })
                    })
            }
    }

    private func catalogDescriptor(_ module: SwordModuleCatalogEntry) -> BibleContentDescriptor {
        Self.descriptor(providerID: id, moduleName: module.name, title: module.title,
            language: module.language, category: module.category, version: module.version, copyright: module.copyright)
    }
}
