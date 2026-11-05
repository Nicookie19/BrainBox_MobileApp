# BrainBox

BrainBox is a local-first Flutter learning app for developers. Its learning
experience is inspired by the principles behind Brilliant's short, guided,
practice-oriented lessons:
clear goals, immediate feedback, visible progress, and a daily learning habit.

The interface is an original BrainBox design and does not copy Brilliant's
branding, artwork, or proprietary lesson content.

## Current Features

- Browse and search learning paths by topic, category, and difficulty.
- Sort courses by recommendation, rating, duration, or title; filter to available lessons.
- Use adaptive desktop navigation and a two-column catalog on larger screens.
- Access saved lessons and downloads directly from the app header.
- Sort in-progress courses by completion or title.
- Open course details and start lessons.
- Complete the starter lesson and daily challenge with one-time XP rewards.
- Save lessons and download lesson content for offline access.
- Track XP, levels, streaks, achievements, and profile statistics.
- Participate in a local community: create posts, vote, report, and reload persisted posts.
- Persist profile, course, bookmark, download, challenge, and community data with SQLite on native platforms and `shared_preferences` on the web.

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

## Supabase connection

The Supabase Flutter client initializes when both build-time values are supplied.
The local `config/supabase.local.json` file contains this development project's
URL and publishable key and is excluded from version control. On a fresh checkout,
copy `config/supabase.example.json` to that path and fill in your project values.

```bash
flutter run -d chrome --dart-define-from-file=config/supabase.local.json
```

For a phone or emulator, omit `-d chrome`. Pass the same flag to release builds:

```bash
flutter build web --release --dart-define-from-file=config/supabase.local.json
```

Running without these values retains local-only mode. Supplying just one value
produces a configuration error. Only use a publishable key in this configuration,
never a server secret or service-role key.

The SQL migration in `supabase/migrations` creates the starter cloud schema.
Client initialization does not create tables, seed cloud courses, or synchronize
existing local data. Screens still use the local repositories. Authentication,
profile creation, per-account local storage, cloud repositories, and offline
synchronization remain to be implemented. Review the schema's reward write
policies before using it for competitive features.

## Local-first mode

Without runtime credentials, community posts and learning data are stored on the
current device and are not synchronized. This is deliberate, so the app can
remain usable offline while cloud repositories are introduced incrementally.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
