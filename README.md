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

## Local-Only Limitations

There is no backend or authentication service configured. Community posts and
learning data are stored on the current device, so they are not synchronized
between users or devices. The repository interfaces are intentionally local-first
so a backend can be introduced without moving persistence logic into widgets.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
