import Testing
@testable import BibleKit

@Test func navigationHonorsProviderOrderAndBoundaries() {
    let keys = ["/II/Preface", "/II/1", "/III/1"]
    #expect(BibleEntryNavigation.adjacentKey(to: keys[1], offset: 1, in: keys) == keys[2])
    #expect(BibleEntryNavigation.adjacentKey(to: keys[0], offset: -1, in: keys) == nil)
    #expect(BibleEntryNavigation.adjacentKey(to: keys[2], offset: Int.max, in: keys) == nil)
    #expect(BibleEntryNavigation.adjacentKey(to: "missing", offset: 0, in: keys) == nil)
}
