# BrainBox Mobile App - Audit Report

**Date**: 2025-09-19
**Flutter Version**: 3.12+
**Platform**: iOS, Android, Web

---

## Executive Summary

The app has a solid foundation with clean architecture (repository pattern, provider state management, go_router navigation). However, several critical issues block production readiness: failing tests, hardcoded lesson content, non-functional UI elements, and missing core features.

---

## Critical Issues (Blocking)

### 1. Test Failures
| Test | Error | Root Cause |
|------|-------|------------|
| `widget_test.dart: BrainBox dashboard loads` | `find.text('A little sharper\ntoday.')` finds 0 widgets | Test expects text that doesn't exist in HomeScreen |
| `community_repository_test.dart: toggles a vote` | Expected `null`, got `UserVote.upvote` | `CommunityPost.copyWith()` doesn't preserve `currentUserVote` when not explicitly passed (missing `?? this.currentUserVote`) |

### 2. Analyzer Issues (28 total)
- 14 unused imports across main.dart and widgets
- 8 unnecessary multiple underscores (`__` → `_`)
- 3 missing braces in if statements (home_screen.dart:151-153)
- 2 unnecessary braces in string interpolation
- 1 unused function `_toast` in main.dart

---

## High Priority Issues (Core Features Incomplete)

### 3. Lesson Engine is Hardcoded/Mock Data
- **File**: `lesson_screen.dart` lines 202-278
- **Issue**: `_getCurrentLesson()` generates mock lessons from hardcoded arrays instead of loading from course modules
- **Impact**: No real lesson progression, no multiple question types, no data-driven content

### 4. Insufficient Course Content
- **File**: `course_repository.dart` lines 48-180
- **Issue**: Only 4 sample courses (Frontend, Python, Flutter, ML, Networking)
- **Requirement**: Need 3+ learning paths with 3+ courses each, 4+ lessons per course

### 5. Streak Logic Missing Timezone/Day Rollover
- **File**: `storage_service.dart` lines 163-194, `user_models.dart` lines 256-330
- **Issue**: Streak stored as simple integers, no date-based calculation, no timezone handling
- **Requirement**: Proper streak calculation with UTC day boundaries

### 6. Daily Challenge Not Rotating Daily
- **File**: `daily_challenge_screen.dart` lines 16-47
- **Issue**: Static hardcoded questions, same every day, no persistence of completion state per day
- **Requirement**: Rotate questions daily, track completion per date

### 7. Profile Menu Items Non-functional
- **File**: `profile_screen.dart` lines 94-135
- **Issue**: All MenuRow onTap handlers are empty (`onTap: () {}`)
- **Missing**: Saved Lessons, Downloads, Appearance, Notifications, Help, Sign Out screens

### 8. Community Reply Dialog Not Implemented
- **File**: `community_screen.dart` line 207
- **Issue**: `_showReplyDialog` has `// TODO: Implement reply dialog`

### 9. No Settings Screen
- **Missing**: Theme selection (light/dark/system), Reset Progress (with confirmation), Notification/Reminder toggle

### 10. Bookmark/Download Buttons Non-functional
- **File**: `lesson_screen.dart` lines 165-180
- **Issue**: Bookmark and download IconButtons have empty onPressed handlers

### 11. Course Progress Tracking Incomplete
- **File**: `app_provider.dart` lines 118-162, `user_models.dart` lines 499-623
- **Issue**: Only tracks `completedLessons`, ignores quizzes, projects, modules
- **CourseProgress model** has fields for all but they're not used

### 12. Achievement Progress Not Tracked
- **File**: `app_provider.dart` lines 63-97, `user_models.dart` lines 332-386
- **Issue**: Achievements created but `progress` field never updated, `isUnlocked` never set to true

### 13. No Resume Where Left Off
- **Issue**: Lesson state (`_currentLessonIndex`, answers) not persisted; navigating away loses progress

---

## Medium Priority Issues

### 14. Search/Filter Empty States
- **Status**: Explore screen has empty state, but could improve UX with suggestions

### 15. Offline Downloads Not Implemented
- **File**: `storage_service.dart` lines 132-160
- **Issue**: Download storage exists but UI doesn't use it; no actual content download logic

### 16. Error Handling Gaps
- **Issue**: Some screens lack proper error states for network/storage failures

---

## Low Priority / Code Quality

### 17. Code Cleanup
- Remove unused imports, fix analyzer warnings, standardize underscore usage

---

## Architecture Notes

**Strengths:**
- Clean separation: Models → Repositories → Providers → Widgets
- Local-first with `shared_preferences` persistence
- Repository interfaces allow backend swap (Firebase ready)
- Good theming system (AppColors, AppTheme)

**Areas for Improvement:**
- Add interfaces/abstract classes for repositories (for Firebase swap)
- Add dependency injection / service locator
- Consider using `freezed` for immutable models with copyWith

---

## Phase 1 Fix Plan - COMPLETED ✓

1. **Fix Analyzer Warnings** - Cleaned up all 28 issues ✓
2. **Fix Test Failures** - Updated tests to match actual UI, fixed `copyWith` bug ✓
3. **Fix Community Vote Toggle** - Fixed `copyWith` in CommunityPost using sentinel pattern ✓
4. **Verify Build** - `flutter analyze` clean, all 10 tests pass ✓

**Commit**: 1bed08c - "Phase 1: Fix analyzer warnings, CommunityPost.copyWith bug, and widget tests"

---

## Phase 2: Complete the Core Learning Loop

### 2.1 Replace Hardcoded Lesson Engine with Data-Driven System
- **Files to modify**: `lesson_screen.dart`, `course_models.dart`, `course_repository.dart`
- **Create**: Lesson content JSON assets or expand Course model with modules/lessons
- **Implement**: Multi-step lesson flow (explanation → multiple choice → fill-in-blank → code ordering)
- **Add**: Immediate feedback, hints, progress bar per lesson
- **Seed**: 3 learning paths × 3+ courses × 4+ lessons each (Git, Python basics, Data Structures, SQL, etc.)

### 2.2 Lesson Completion & XP System
- **Files**: `app_provider.dart`, `user_models.dart`, `storage_service.dart`
- **Fix**: Award XP only once per lesson (track completed lesson IDs)
- **Implement**: Level progression, streak updates, course progress, achievement unlocks
- **Streak logic**: UTC day boundaries, timezone-aware day rollover

### 2.3 Daily Challenge Rotation
- **File**: `daily_challenge_screen.dart`
- **Implement**: Date-based question rotation (seeded RNG per date)
- **Track**: Completion per date (not just once ever)
- **Persist**: Daily challenge state with date key

### 2.4 Resume Where Left Off
- **Persist**: Lesson index, answered questions, scroll position
- **Restore**: On lesson screen re-entry

---

## Phase 3: Fix and Finish Existing Features

### 3.1 Profile Menu Items
- **File**: `profile_screen.dart`
- **Implement**: Saved Lessons, Downloads, Appearance, Notifications, Help, Sign Out screens

### 3.2 Community Replies
- **File**: `community_screen.dart`, `community_repository.dart`
- **Implement**: Reply dialog, nested replies, reply persistence

### 3.3 Settings Screen
- **Create**: `settings_screen.dart`
- **Features**: Theme (light/dark/system), Reset Progress (confirm dialog), Notification toggle

### 3.4 Bookmarks & Downloads
- **Files**: `lesson_screen.dart`, `storage_service.dart`, `app_provider.dart`
- **Implement**: Functional bookmark/download buttons, offline content access

### 3.5 Course Progress Tracking
- **Files**: `app_provider.dart`, `course_repository.dart`
- **Track**: Modules, lessons, quizzes, projects completion

### 3.6 Achievement System
- **Files**: `app_provider.dart`, `user_models.dart`
- **Update**: Progress tracking, auto-unlock on criteria met

### 3.7 Error/Empty/Loading States
- **All screens**: Consistent error boundaries, empty states, loading skeletons