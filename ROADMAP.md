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
   - [x] Separate verse and keyed-entry locations with provider-native resolution.
   - [x] Optional reading protocol with text, XHTML, attribution, and cancellation.
   - Chapter/passage navigation and ordered keyed-entry navigation.
   - Search, availability, and download lifecycle APIs.

3. `BibleKitSword` adapter
   - [x] Optional package product depending on tagged SwordKit.
   - [x] Map SWORD catalogs and module capabilities into BibleKit descriptors.
   - [x] Read individual Bible verses and keyed entries off the main thread.
   - Expose searching, navigation, and module lifecycle actions.

4. Authorized and custom feed providers
   - HTTPS feed contract, trust policy, attribution display requirements, and
     per-provider cache/download restrictions.

5. Consumer integration
   - Migrate SwordReader from direct SwordKit use to BibleKit and the optional
     SWORD adapter, preserving existing offline behavior.

## Extraction ownership and sequence

- ModernSwordAPI owns native engine maintenance; SwordKit owns its Swift bridge,
  module decoding, native versification, and SWORD transport.
- BibleKit owns provider-neutral catalog, reading, capability, and attribution
  contracts; BibleKitSword maps the engine into those contracts.
- BibleUI owns reusable reader rendering, typography, content selection, and
  catalog presentation. SwordReader owns scenes, product navigation, storage,
  Apple Watch transfer, Handoff, reminders, and release settings.
- Add navigation/availability contracts before replacing SwordReader's
  ScriptureService. Preserve rich footnotes, lexical attributes, and cross
  references during that migration rather than reducing them to plain strings.
- Extract reader typography/rendering into BibleUI after those contracts are
  tested; then migrate library/catalog components. Validate macOS, iOS, and
  watchOS at each consumer migration.
