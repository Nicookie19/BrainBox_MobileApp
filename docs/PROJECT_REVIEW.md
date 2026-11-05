# BrainBox project review

Reviewed 2026-11-05. This review covered the Flutter models and repositories,
learning and challenge state, local storage, settings, community interactions,
main navigation and screens, lesson assets through the test suite, and the
platform/build configuration. It is not a guarantee that every possible bug has
been eliminated.

## Fixed

- Corrected enum deserialization for achievements, statistics, interests, post
  types, quiz question types, and activities. Both enum-qualified values and
  short names remain readable.
- Preserved saved profile names on initialization; community posts and replies
  now use the saved profile name.
- Made provider initialization seed a missing catalog. Progress reset now clears
  learning history while retaining the catalog, identity, preferences,
  bookmarks, downloads, and community posts.
- Rejected unknown lessons before awarding XP or modifying completion counts.
- Made challenge rewards idempotent for repeated calls, including rapid taps and
  provider restarts. Results are saved when finishing the challenge rather than
  when leaving the results page. The challenge keeps its start date, and saved
  results use that same date. Calendar-date question seeds no longer depend on
  the device timezone offset.
- Validated negative or malformed lesson progress indices; bounded restored
  step positions to the available content. Restored multiple-choice feedback
  now reflects the actual answer. Non-choice steps in the old format require a
  reattempt because their original answers were never saved.
- Awaited lesson completion before advancing, guarded repeated completion taps,
  checked widget lifetime after async loading, and made completion messages
  distinguish lesson completion from full-course completion. The final dialog
  reports the XP gained by that completion, including zero on replay.
- Rejected replies to nonexistent posts or parent replies before writing data.
- Connected the report action to persistent local reporting. Replaced the
  nonfunctional liked-post action with the existing downvote functionality.
- Replaced hardcoded learning-tile lesson names and reward totals with actual
  lesson data.
- Fixed narrow-screen overflows in dashboard cards, learning tiles, profile
  progress, and community actions. Added populated-screen tests so empty
  fixtures cannot conceal these layout errors.
- Implemented copying a complete local JSON backup from Settings. No restore
  workflow is implemented yet.
- Corrected README claims about native storage and Supabase: native storage is
  SQLite; the cloud schema is not connected to a runtime client.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: 50 tests pass, including persistence, repeated rewards,
  progress reset, invalid data, lesson resume, and 320-pixel screen checks.
- `flutter build web --release`: succeeds, including the tool's Wasm dry run.

## Remaining limitations and follow-up work

- Settings still expose stored preferences whose runtime behavior is not
  implemented: system theme selection, notifications, reduced motion, and
  haptic feedback. The app currently always uses its dark theme. These need
  proper integration, rather than simply persisting the switches.
- Cloud authentication, synchronization, and remote moderation are absent.
  Reports are local records; they are not delivered to a moderator. The SQL
  migration has not been applied or validated against a live Supabase instance.
- Storage writes span multiple keys and are not transactional. A disk failure
  or process termination partway through an update can still leave partial
  state. A transaction-capable repository boundary is needed for crash-safe
  reward and progress updates across all backends.
- Streak/weekly activity day boundaries use UTC, while daily challenges use the
  local calendar. Unifying them requires a deliberate migration of saved day
  keys, rather than silently reinterpreting existing activity.
- Native release signing remains unfinished: Android release builds use debug
  signing. Native builds, device behavior, and accessibility with large text
  sizes were not verified in this review.
- Older data already overwritten by previous parsing/name bugs cannot always
  be reconstructed. These fixes preserve valid saved data going forward.
