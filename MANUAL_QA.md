# BrainBox Mobile App - Manual QA Checklist

## Overview
This document provides step-by-step manual testing procedures to verify all implemented features work correctly on physical devices (iOS, Android) and web.

---

## Pre-Test Setup

1. **Install dependencies**: `flutter pub get`
2. **Run on device/emulator**: `flutter run -d <device_id>`
3. **Clear app data**: Uninstall and reinstall between major test runs
3. **Test on platforms**: iOS Simulator, Android Emulator, Chrome (Web)

---

## Test Scenarios

### 1. Onboarding & First Launch
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1.1 | Fresh install → Launch app | Onboarding screen shows, "Get Started" button works |
| 1.2 | Complete onboarding | Navigates to Home screen, shows "Good morning" greeting |
| 1.3 | Relaunch app | Skips onboarding, goes directly to Home |
| 1.4 | Check persistence | User profile, preferences, progress retained |

### 2. Home Screen
| Step | Action | Expected Result |
|------|--------|-----------------|
| 2.1 | Verify stats | Shows streak, XP, level badge |
| 2.2 | Tap "Continue Learning" | Navigates to lesson screen for enrolled course |
| 2.3 | Tap Daily Challenge card | Opens daily challenge screen |
| 2.4 | Scroll learning paths | Shows 3 learning paths horizontally |
| 2.5 | Tap learning path | Navigates to explore screen filtered by path |

### 3. Learning Flow (Lesson Engine)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 3.1 | Navigate to course → lesson | Lesson screen loads with title, progress bar |
| 3.2 | Explanation step | Shows content, "Continue" button advances |
| 3.3 | Multiple choice question | Shows question, 4 options, select → immediate feedback |
| 3.4 | Wrong answer | Shows red highlight, explanation, "Try again" |
| 3.5 | Correct answer | Shows green highlight, explanation, "Next" |
| 3.6 | True/False question | Two buttons (True/False), feedback on select |
| 3.7 | Fill-in-the-blank | Text input, case-insensitive check, hint button |
| 3.8 | Code ordering | Drag/tap to reorder, "Check order" validates |
| 3.9 | Hint button | Shows hint (max 2), tracks hints used |
| 3.9 | Complete lesson | Shows XP earned, "Next Lesson" / "Complete Course" |
| 3.10 | Navigate away mid-lesson | Resume dialog offers "Resume" / "Start Over" |
| 3.10 | Resume after kill app | Restores step, answers, scroll position |

### 4. Daily Challenge
| Step | Action | Expected Result |
|------|--------|-----------------|
| 4.1 | Open Daily Challenge | Shows today's 5 questions, progress 0/5 |
| 4.2 | Answer questions | Progress updates, immediate feedback |
| 4.3 | Complete all 5 | Shows "Challenge Complete! +50 XP", "Come back tomorrow" |
| 4.4 | Reopen same day | Shows "Already completed! Come back tomorrow" |
| 4.5 | Wait until midnight | New questions load, progress resets |
| 4.5 | App open at midnight | Auto-refreshes to new challenge |

### 5. Streak & XP System
| Step | Action | Expected Result |
|------|--------|-----------------|
| 5.1 | Complete first lesson | XP +25, streak = 1 |
| 5.2 | Complete lesson next day | Streak = 2, XP increases |
| 5.3 | Skip a day | Streak resets to 1 |
| 5.4 | Level up threshold | Level badge updates, celebration |
| 5.5 | Change device timezone | Streak uses local calendar day |
| 5.6 | Change system clock | Streak uses local calendar day (not UTC) |

### 6. Course Progress & Course Detail
| Step | Action | Expected Result |
|------|--------|-----------------|
| 6.1 | Open course detail | Shows modules, lessons, progress % |
| 6.2 | Complete lessons | Module progress updates, course % updates |
| 6.3 | Complete all lessons | Course marked "Completed", badge earned |
| 6.4 | Course detail from home | "Continue Learning" goes to next incomplete lesson |

### 6. Achievements
| Step | Action | Expected Result |
|------|--------|-----------------|
| 6.1 | Open profile → Achievements | Shows locked/unlocked badges with progress |
| 6.2 | Complete first lesson | "First Lesson" unlocks, +XP toast |
| 6.3 | 7-day streak | "On Fire" unlocks, +50 XP |
| 6.4 | Complete first course | "Starter" unlocks, +100 XP |
| 6.5 | 10 lessons | "Scholar" unlocks, +75 XP |
| 6.6 | 50 lessons | "Master Learner" unlocks, +300 XP |
| 6.7 | 1000 total XP | "Rising Star" unlocks, +100 XP |
| 6.8 | 30-day streak | "Dedicated" unlocks, +200 XP |

### 7. Daily Challenge
| Step | Action | Expected Result |
|------|--------|-----------------|
| 7.1 | Open daily challenge | Shows 5 questions, fixed for today's date |
| 7.2 | Answer correctly | Green feedback, score increments |
| 7.3 | Answer incorrectly | Red feedback, explanation shown |
| 7.4 | Complete all 5 | "Challenge Complete! +50 XP" |
| 7.5 | Reopen same day | "Already completed! Come back tomorrow" |
| 7.6 | Date change (midnight) | New questions, can play again |

### 8. Profile & Settings
| Step | Action | Expected Result |
|------|--------|-----------------|
| 8.1 | Tap profile avatar | Opens profile screen |
| 8.2 | Profile shows | Avatar, name, level, XP, streak, stats |
| 8.3 | Tap "Saved Lessons" | Opens saved lessons list |
| 8.4 | Tap "Downloads" | Opens downloads list |
| 8.5 | Tap "Appearance" | Opens settings → theme selector |
| 8.6 | Tap "Notifications" | Opens settings → reminder time picker |
| 8.7 | Tap "Help & Support" | Opens FAQ accordion screen |
| 8.8 | Tap "Sign Out" | Confirmation dialog, optional data delete |
| 8.9 | Sign out + delete data | Clears all progress, returns to onboarding |
| 8.10 | Sign out + keep data | Returns to onboarding, data preserved |

### 9. Settings Screen
| Step | Action | Expected Result |
|------|--------|-----------------|
| 9.1 | Theme: System | Follows OS theme |
| 9.2 | Theme: Light | Forces light mode |
| 9.3 | Theme: Dark | Forces dark mode |
| 9.4 | Daily reminder: ON + time | Notification scheduled at chosen time |
| 9.5 | Daily reminder: OFF | Cancels notification |
| 9.6 | Reset Progress → Confirm → Type "RESET" | All progress cleared, returns to onboarding |
| 9.7 | Reset Progress → Cancel | Dialog dismisses, nothing changed |

### 10. Community
| Step | Action | Expected Result |
|------|--------|-----------------|
| 10.1 | Open Community tab | Shows posts list, FAB to create post |
| 10.2 | Tap post | Opens post detail with replies |
| 10.3 | Tap "Reply" on post | Opens reply input, submit adds reply |
| 10.4 | Tap "Reply" on reply | Nested reply (indented, max depth 2) |
| 10.5 | Reply to depth-2 reply | Attaches to depth-1 parent |
| 10.5 | Upvote/Downvote | Score updates, toggle works |
| 10.6 | Max length | 2000 chars, counter shows remaining |
| 10.7 | Max depth | Depth-2 replies have no "Reply" button |

### 11. Bookmarks & Downloads
| Step | Action | Expected Result |
|------|--------|-----------------|
| 11.1 | Tap bookmark in lesson | Icon fills, "Saved" toast |
| 11.2 | Tap bookmark again | Icon outlines, "Removed" toast |
| 11.3 | Profile → Saved Lessons | Lists bookmarked lessons |
| 11.4 | Profile → Downloads | Lists downloaded lessons |
| 11.5 | Tap download in lesson | Icon changes: idle → downloading → downloaded |
| 11.6 | Downloaded lesson | Opens offline (no network) |
| 11.7 | Delete download | Removes from list, frees space |

### 12. Daily Reminders
| Step | Action | Expected Result |
|------|--------|-----------------|
| 12.1 | Settings → Notifications → ON | Permission requested (if needed) |
| 12.2 | Set time (e.g., 19:00) | Time saved |
| 12.3 | Wait until time | Local notification fires |
| 12.4 | Tap notification | Opens app to Daily Challenge |
| 12.5 | Toggle OFF | Notification cancelled |

### 13. Help & Support
| Step | Action | Expected Result |
|------|--------|-----------------|
| 13.1 | Profile → Help & Support | FAQ accordion opens |
| 13.2 | Tap FAQ question | Expands/collapses answer |
| 13.3 | Scroll to bottom | "Contact Support" email link |

### 14. Explore & Search
| Step | Action | Expected Result |
|------|--------|-----------------|
| 14.1 | Explore tab | Shows all courses, filters work |
| 14.2 | Search query | Filters courses in real-time |
| 14.3 | Category filter | Filters by category |
| 14.4 | Difficulty filter | Filters by difficulty |
| 14.5 | Clear filters button | Resets all filters |
| 14.6 | Empty search + filters | Shows "No courses match" + "Clear filters" |

### 15. Downloads & Offline
| Step | Action | Expected Result |
|------|--------|-----------------|
| 15.1 | Tap download on lesson | Progress indicator, then "Downloaded" |
| 15.2 | Enable airplane mode | Lesson still opens, content loads |
| 15.3 | Delete download | Removed from list, space freed |

### 16. Resume & Persistence
| Step | Action | Expected Result |
|------|--------|-----------------|
| 16.1 | Mid-lesson → Home → Lesson | "Resume" / "Start Over" dialog |
| 16.2 | Select "Resume" | Restores step, answers, scroll |
| 16.3 | Select "Start Over" | Resets to step 0 |
| 16.4 | Kill app mid-lesson → Reopen | Same resume dialog |
| 16.5 | Content updated → Open lesson | "Content updated, starting fresh" |

### 17. Sign Out
| Step | Action | Expected Result |
|------|--------|-----------------|
| 17.1 | Profile → Sign Out | Confirmation dialog |
| 17.2 | Cancel | Dialog dismisses |
| 17.3 | Sign Out (keep data) | Returns to onboarding, data intact |
| 17.4 | Sign Out + Delete Data | Returns to onboarding, all data cleared |

---

## Cross-Platform Checks

| Platform | Test |
|----------|------|
| iOS Simulator | All flows work, keyboard handling, safe areas |
| Android Emulator | All flows work, back button handling, permissions |
| Chrome (Web) | All flows work, responsive layout, keyboard shortcuts |
| Tablet (iPad/Android) | Two-pane layouts where applicable, landscape |

---

## Performance Checks

| Metric | Target |
|--------|--------|
| App launch (cold) | < 2s |
| Lesson screen load | < 500ms |
| Screen transitions | 60 FPS, no jank |
| Image loading | Placeholder → fade in |
| Memory usage | < 150MB typical |

---

## Accessibility

| Feature | Test |
|---------|------|
| VoiceOver/TalkBack | All elements labeled, hints work |
| Dynamic Type | Text scales, layout adapts |
| Color Contrast | WCAG AA minimum |
| Touch Targets | ≥ 48x48dp |

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA Lead | | | |
| Engineering Lead | | | |
| Product Owner | | | |

---

## Notes
- Test on real devices, not just simulators
- Test with network throttling (3G, offline)
- Test with different system languages (RTL)
- Test with large text sizes (Accessibility)
- Verify analytics events fire correctly