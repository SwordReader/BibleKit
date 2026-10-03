# BibleKit Roadmap

BibleKit is the provider-agnostic domain framework for Bible, study, and
licensed content. Its core contains neither UI nor a SWORD engine dependency.

Reviewed October 3, 2026 through `8b2fc99` (tag `0.3.2`). The core is engine-free;
the optional `BibleKitSword` product depends on SwordKit.

## Principles

- Provider ownership, licenses, attribution, and permissions are explicit.
- No provider is assumed to support offline storage, search, or export.
- Stable provider-scoped identifiers support application persistence and sync.
- SWORD support belongs in the optional `BibleKitSword` adapter, not the core.

## Ordered milestones

1. Core catalog and provider contracts
   - [x] Content descriptors, capabilities, licensing, attribution, and provider IDs.
   - [x] Async provider catalog protocol and test-provider coverage.

2. Unified reading contracts
   - [x] Separate verse and keyed-entry locations with provider-native resolution.
   - [x] Optional reading protocol with text, XHTML, attribution, and cancellation.
   - [x] Provider-native book/chapter and ordered keyed-entry navigation contracts.
   - [x] Attributed chapter content with headings, footnotes, and cross references.
   - [x] Search modes, scope, scores, and progress contracts.
   - [x] Provider-neutral parallel rows and word-link values.
   - [ ] General passage API and provider-neutral availability/download lifecycle.

3. `BibleKitSword` adapter
   - [x] Optional package product depending on tagged SwordKit.
   - [x] Map SWORD catalogs and module capabilities into BibleKit descriptors.
   - [x] Read individual Bible verses and keyed entries off the main thread.
   - [x] Expose searching, navigation, and parallel chapter comparison.
   - [x] Local/remote catalog inspection, installation, removal, and refresh.
   - [x] User-selected archive installation for paired module delivery.
   - [x] Opt-in real ASV integration coverage for reading, book navigation,
     chapter fidelity, and scoped search; verified locally on macOS.
   - [ ] Make module lifecycle contracts reusable beyond the SWORD adapter;
     current repository/progress parameters remain SwordKit-specific.

4. Authorized and custom feed providers
   - [x] Validated read-only HTTPS JSON snapshot feeds with ordered locations.
   - [x] Explicit load, bounded input, no redirects, no credential-bearing URLs,
     ephemeral transport, and documented attribution/storage responsibilities.
   - [ ] Authenticated publisher adapters, negotiated permissions/entitlements,
     and provider-specific cache/download policies. No publisher access is implied.

5. Consumer integration
   - [x] SwordReader service and Watch migration merged in PR #16; macOS tests
     and generic iOS/watchOS builds passed locally and on GitHub. Real ASV tests
     verify adapter reading, chapter, navigation, and search fidelity.
   - [ ] Complete running-app/device acceptance of offline, rich content,
     module transfer, and continuity behavior after migration.
   - [x] Document baseline provider/adapter usage, feed policy, integration checks,
     and pre-1.0 compatibility policy. Future contracts require additional docs.

6. Read Aloud content support
   - [ ] Supply ordered, provider-neutral narration text and resolved reading
     locations for Scripture and keyed entries, preserving language and attribution.
   - [ ] Define predictable treatment of verse numbers, headings, footnotes,
     markup, and entry/chapter boundaries without coupling to an Apple speech API.
   - [ ] Review provider-specific permission requirements for local narration;
     do not infer rights to synthesize, save, cache, or export audio from reading
     capability alone. Model restrictions explicitly where needed.
   - [ ] Test narration text and location mapping with SWORD and custom-feed
     providers; keep playback, voice preferences, audio sessions, and Siri in apps.

## Extraction ownership and sequence

- ModernSwordAPI owns native engine maintenance; SwordKit owns its Swift bridge,
  module decoding, native versification, and SWORD transport.
- BibleKit owns provider-neutral catalog, reading, capability, and attribution
  contracts; BibleKitSword maps the engine into those contracts.
- BibleUI owns reusable reader rendering, typography, content selection, and
  catalog presentation. SwordReader owns scenes, product navigation, storage,
  Apple Watch transfer, Handoff, reminders, and release settings.
- Navigation/search contracts are implemented; general availability/lifecycle
  contracts are still pending. Validate those boundaries while replacing SwordReader's
  ScriptureService. Preserve rich footnotes, lexical attributes, and cross
  references during that migration rather than reducing them to plain strings.
- Extract reader typography/rendering into BibleUI after those contracts are
  tested; then migrate library/catalog components. Validate macOS, iOS, and
  watchOS at each consumer migration.
