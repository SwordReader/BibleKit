# BibleKit Roadmap

BibleKit is the provider-agnostic domain framework for Bible, study, and
licensed content. It does not contain a UI or a SWORD engine dependency.

## Principles

- Provider ownership, licenses, attribution, and permissions are explicit.
- No provider is assumed to support offline storage, search, or export.
- Stable provider-scoped identifiers support application persistence and sync.
- SWORD support belongs in the optional `BibleKitSword` adapter, not the core.

## Ordered milestones

1. Core catalog and provider contracts
   - Content descriptors, capabilities, licensing, attribution, and provider IDs.
   - Async provider catalog protocol and in-memory test provider.

2. Unified reading contracts
   - Scripture and keyed-entry references without flattening provider-specific
     semantics.
   - Read, search, availability, and download lifecycle APIs.

3. `BibleKitSword` adapter
   - [x] Optional package product depending on tagged SwordKit.
   - [x] Map SWORD catalogs and module capabilities into BibleKit descriptors.
   - Expose provider-scoped reading, searching, and module lifecycle actions.

4. Authorized and custom feed providers
   - HTTPS feed contract, trust policy, attribution display requirements, and
     per-provider cache/download restrictions.

5. Consumer integration
   - Migrate SwordReader from direct SwordKit use to BibleKit and the optional
     SWORD adapter, preserving existing offline behavior.
