# BibleKit

BibleKit is a provider-agnostic Swift foundation for Bible, study, licensed,
and custom-feed content on Apple platforms. It models catalogs, capabilities,
licenses, and attribution without assuming that every provider permits the same
reading, download, search, or export behavior.

SWORD support is supplied as a separate `BibleKitSword` adapter
that depends on [SwordKit](https://github.com/SwordReader/SwordKit). This keeps
the core independent of the SWORD engine and its licensing obligations.

`BibleKitSword` is now available as an optional package product. It exposes
installed SWORD modules through the shared provider catalog API; applications
using it remain responsible for complying with SwordKit, SWORD, and module
licenses.

The `BibleReadingProvider` protocol reads one Bible verse or module-native keyed
entry. Results preserve resolved references, plain text, XHTML, and attribution.
The SWORD adapter runs native reading off the main thread and cooperates with
task cancellation between engine calls. The adapter also exposes book/chapter
navigation, keyed-entry order, search, parallel chapters, and SWORD module
installation/removal. Repository and transfer types currently remain
SwordKit-specific; provider-neutral download management is a future milestone.

The core also supplies validated, read-only HTTPS JSON feeds. See
[feed format and trust policy](Docs/FEEDS.md). Publisher authentication and
entitlement handling require a provider-specific implementation and permission;
neither the package nor a feed grants rights to copyrighted content.

## Usage

Import `BibleKit` for engine-independent contracts. Add `BibleKitSword` only
when using SWORD modules:

```swift
import BibleKit
import BibleKitSword
import SwordKit

let library = try SwordLibrary(directory: moduleDirectory)
let provider = SwordContentProvider(library: library)
let catalog = try await provider.catalog()
let chapter = try await provider.chapter(
    contentID: BibleContentID(rawValue: "ASV"), reference: "John 3"
)
```

Applications retain responsibility for storage, user consent, navigation,
credentials, and release policy. `BibleUI` presents these contracts without
depending directly on SWORD. Pre-1.0 minor releases may change API; tagged patch
releases preserve source compatibility within their minor series.

## Verification

Run `swift test`. To additionally verify native reading, 66-book navigation,
chapter text, and scoped search using an installed ASV module:

```sh
BIBLEKIT_TEST_MODULE_DIRECTORY=/path/to/sword-root swift test --no-parallel
```

The directory must contain `mods.d/asv.conf` and the module data tree. Tests do
not download content automatically or bundle module text. Integration coverage
is explicitly skipped without this environment variable.
