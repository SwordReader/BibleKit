# BibleKit Agent Instructions

BibleKit owns provider-neutral catalog, reading, navigation, search, capability,
and attribution contracts. BibleKitSword is the optional adapter for public
SwordKit. The core must not import SwordKit or UI frameworks.

## Workflow

Work on one roadmap milestone at a time. Inspect existing implementation, add
Swift Testing regression tests first where practical, implement the smallest
complete change, run `swift test`, review the diff, and commit only when tests
pass. Stop after the milestone commit unless explicitly asked to continue.
Update `ROADMAP.md` with committed progress; distinguish implementation from
consumer/device validation. Prefer local checks over repeated GitHub CI runs.

## Boundaries

- Use tagged public SwordKit releases; fix engine defects upstream, not here.
- Preserve provider-scoped identifiers, native reference order, rich content,
  licenses, and attribution. Capabilities must reflect actual provider behavior.
- Do not assume reading implies permission to cache, search, export, or download.
- Keep publisher secrets, app persistence, navigation, and release policy out of
  the framework. Custom feeds require explicit trust and bounded transport.
- `Package.swift` is the source of truth for supported platforms. Validate
  affected Apple-platform consumers before claiming a migration complete.
- Coordinate with active work in other chats; do not overwrite their changes or
  publish a tag that includes unvalidated work.

Use `import Testing`, not XCTest, for new Swift tests.
