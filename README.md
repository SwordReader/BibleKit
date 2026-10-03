# BibleKit

BibleKit is a provider-agnostic Swift foundation for Bible, study, licensed,
and custom-feed content on Apple platforms. It models catalogs, capabilities,
licenses, and attribution without assuming that every provider permits the same
reading, download, search, or export behavior.

SWORD support is supplied as a separate `BibleKitSword` adapter
that depends on [SwordKit](https://github.com/orbeavers14/SwordKit). This keeps
the core independent of the SWORD engine and its licensing obligations.

`BibleKitSword` is now available as an optional package product. It exposes
installed SWORD modules through the shared provider catalog API; applications
using it remain responsible for complying with SwordKit, SWORD, and module
licenses.

The `BibleReadingProvider` protocol reads one Bible verse or module-native keyed
entry. Results preserve resolved references, plain text, XHTML, and attribution.
The SWORD adapter runs native reading off the main thread and cooperates with
task cancellation between engine calls. Navigation, chapter/passage APIs,
search, and download management remain on the roadmap; SwordReader has not yet
migrated to this contract.
