# BrainBox

BrainBox is a local-first Flutter learning app for developers. Its learning
experience is inspired by the principles behind Brilliant's short, guided,
practice-oriented lessons:
clear goals, immediate feedback, visible progress, and a daily learning habit.

The interface is an original BrainBox design and does not copy Brilliant's
branding, artwork, or proprietary lesson content.

## Current Features

- Browse, search, and filter learning paths.
- Open course details and start lessons.
- Complete the starter lesson and daily challenge with one-time XP rewards.
- Save lessons and download lesson content for offline access.
- Track XP, levels, streaks, achievements, and profile statistics.
- Participate in a local community: create posts, vote, report, and reload persisted posts.
- Persist profile, course, bookmark, download, challenge, and community data with `shared_preferences`.

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter analyze
flutter test
```

## Cloud backend (Supabase)

BrainBox works locally by default, which keeps development and offline learning
available without a cloud account. To enable Supabase, create a project, run the
migration in `supabase/migrations`, then provide its credentials at build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

The schema covers user profiles, course progress, bookmarks, the community,
votes, replies, and daily challenge completion with row-level security. Never
place a Supabase service-role key in this application.

## Local-first mode

Without runtime credentials, community posts and learning data are stored on the
current device and are not synchronized. This is deliberate, so the app can
remain usable offline while cloud repositories are introduced incrementally.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
