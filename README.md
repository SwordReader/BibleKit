# BibleKit

BibleKit is a provider-agnostic Swift foundation for Bible, study, licensed,
and custom-feed content on Apple platforms. It models catalogs, capabilities,
licenses, and attribution without assuming that every provider permits the same
reading, download, search, or export behavior.

SWORD support is intentionally planned as a separate `BibleKitSword` adapter
that depends on [SwordKit](https://github.com/orbeavers14/SwordKit). This keeps
the core independent of the SWORD engine and its licensing obligations.

`BibleKitSword` is now available as an optional package product. It exposes
installed SWORD modules through the shared provider catalog API; applications
using it remain responsible for complying with SwordKit, SWORD, and module
licenses.
