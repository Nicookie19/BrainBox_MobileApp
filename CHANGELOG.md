# BrainBox Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-20

### Phase 1: Foundation & Bug Fixes
- Fixed analyzer warnings and code quality issues
- Fixed `copyWith` bug in UserProfile model
- Added widget tests for core screens
- Set up Flutter project structure with GoRouter navigation
- Implemented dark theme with custom color system (AppColors)
- Added flutter_animate for smooth UI animations

### Phase 2: Core Learning Loop

#### Phase 2.1: Data-Driven Lesson Engine
- Created 4 lesson content JSON files: `frontend-foundations`, `python-essentials`, `data-structures`, `sql-basics`
- Each course has 4 lessons with 5 steps each (explanation, multiple_choice, fill_in_blank, code_ordering)
- Built `LessonRepository` to load lessons from JSON assets
- Rewrote `LessonScreen` to use data-driven content with support for all 4 step types
- Added `LessonModuleData`, `LessonModule`, `Lesson`, `LessonStep` models

#### Phase 2.2: Lesson Completion & XP System
- Added `completedLessonIds` and `lastLessonCompletedAt` to `UserProfile`
- Implemented streak logic with UTC day boundaries (handles day rollover correctly)
- Added `copyWith` methods to `Achievement` and `UserStats` models
- Updated `completeLesson` to award XP only once per lesson (tracks by `courseId:lessonId`)
- Added achievement progress tracking for `lessonsCompleted` and `streakDays`
- XP rewards: 25 XP per lesson, 50 XP per daily challenge

#### Phase 2.3: Daily Challenge Rotation
- Created `DailyChallengeRepository` with 20+ questions across JS, Python, CSS, CS topics
- Implemented deterministic daily question selection using date-based seeding
- Added per-date completion tracking (not just once ever)
- Added fixed-date support for deterministic testing
- Daily challenge screen uses date-based questions with per-date persistence

#### Phase 2.4: Resume Where Left Off
- Created `LessonProgressRepository` for saving/restoring lesson progress
- Added `_answeredSteps` tracking for all question types
- Implemented `_saveProgress()` to persist current step, answers, and completion state
- Added `_loadLessonProgress()` to restore progress on lesson load
- Progress saved on answer selection, step navigation, and lesson completion
- Progress keyed by `courseId:lessonId` for multi-lesson support

### Phase 3: Fix and Finish Existing Features

#### Bookmark Functionality
- Added `toggleBookmark()` and `isBookmarked()` methods to `AppProvider`
- Bookmark button in lesson screen now toggles bookmarks with visual feedback
- Created `BookmarksScreen` (`/bookmarks` route) showing all saved lessons with course context and remove option
- Added "Saved Lessons" menu item in Profile that navigates to bookmarks screen

#### Settings Screen (`/settings` route)
- **Theme Selector**: System / Dark mode toggle
- **Notifications**: Push notifications, Email notifications, Daily reminder toggles
- **Preferences**: Haptic feedback, Reduce motion, Auto-play videos, Download on WiFi only
- **Data & Privacy**: Export data dialog, Reset progress with confirmation dialog
- **About**: App version, Terms of Service, Privacy Policy, Rate the app

#### Profile Menu Actions
- "Saved Lessons" → navigates to bookmarks screen
- "Downloads" → placeholder for offline content management
- "Appearance" → navigates to settings screen
- "Notifications" → navigates to settings screen
- "Help & Support" → placeholder
- "Sign Out" → confirmation dialog, clears all local data via `StorageService.clearAll()`

#### Community Replies
- Added reply storage in `CommunityRepository` with nested reply support
- Added `createReply()`, `getReplies()`, `toggleReplyVote()`, `acceptAnswer()` methods
- Added `PostReply.copyWith()` to model for immutable updates
- Implemented `_ReplyBottomSheet` modal with:
  - Threaded reply display with upvote/downvote buttons
  - Reply input with "replying to" indicator for nested replies
  - Nested reply support (replies to replies)
  - Real-time refresh after posting/voting
  - Accepted answer badge for question posts

### Technical Improvements
- All tests pass (10/10): unit tests for community repository, widget tests for screens
- Flutter analyzer clean (0 errors, 0 warnings)
- Type-safe models with JSON serialization
- Provider pattern for state management
- Local persistence via SharedPreferences (StorageService)
- GoRouter for declarative routing with ShellRoute for bottom navigation

## [0.2.0] - 2026-09-15

### Phase 1 Complete
- Project initialization with Flutter, Provider, GoRouter, flutter_animate
- Core models: UserProfile, UserLevel, UserStats, Achievement, Course, Lesson, CommunityPost
- StorageService for local persistence
- AppTheme with dark mode support
- Basic screen structure: Home, Explore, Learn, Community, Profile
- Bottom navigation with animated NavigationBar
- Course repository with sample data

## [0.1.0] - 2026-09-10

### Initial Setup
- Flutter project creation
- Dependency setup (provider, go_router, flutter_animate, shared_preferences)
- Basic folder structure following clean architecture principles
- Git repository initialization

---

## Upcoming (Phase 4: Auth & Backend)

- [ ] Firebase Authentication (email/password, Google, Apple)
- [ ] Cloud Firestore for syncing progress across devices
- [ ] Firebase Analytics for usage tracking
- [ ] Remote config for feature flags
- [ ] Push notifications via FCM

## Upcoming (Phase 5: Quality & Polish)

- [ ] Comprehensive widget and integration tests
- [ ] Accessibility improvements (semantics, contrast, text scaling)
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Performance profiling and optimization
- [ ] App store assets and metadata
- [ ] Light theme support
- [ ] Onboarding flow for new users