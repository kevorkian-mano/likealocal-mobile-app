# LikeLocal Full Requirements Implementation Plan

## Overview

After deep analysis of the codebase and the milestone requirements, here are the key gaps and issues to fix across the entire app. All 12 phases are claimed as "Implemented" in the MD, but several critical areas have real problems including mock data, broken UI, non-functional buttons, and missing app bars.

## Critical Issues Found

> [!CAUTION]
> **Mock/Hardcoded Data in Production Code:**
> - `maps_page.dart` L556: hardcoded `'Zamalek, Cairo'` location — should use real gem coordinates via reverse geocoding or be dynamic
> - `maps_page.dart` L470-471: `"You've used 2 of your 5 monthly pins"` — FULLY HARDCODED. Should use `user.savedGems.length` from Firestore
> - `maps_page.dart` L478: `value: 0.4` hardcoded progress — should be `user.savedGems.length / limit`
> - `maps_page.dart` L720-723: "Trending Only" switch always `false`, `onChanged: (v) {}` — non-functional

> [!WARNING]
> **Missing AppBars on several screens** — multiple pages use a top "overlay" approach instead of a proper, unified AppBar. The requirement states "all pages have the app bar nicely shown."

> [!IMPORTANT]
> **Profile page settings not working:**
> - "Personalized Maps" row has `onTap: () {}` — no action wired
> - No ability to view/manage saved gems (pinned places) from the profile
> - The "Pins" section in maps shows fake data instead of real Firestore data

## Proposed Changes

### 1. Maps Page — Fix Real Pins Data & Mock Data

#### [MODIFY] maps_page.dart
- Replace the hardcoded "Used Pins" card with real data from `UserProvider.user.savedGems`
- Replace hardcoded location `'Zamalek, Cairo'` with `gem.category` or real coord label
- Fix the "Trending Only" filter to actually work with `gem.isTrending`
- Add `AppBottomNavBar` properly (already present, verify correct index)
- Fix progress bar to show `savedGems.length / limit`

### 2. Profile Page — Fix All Buttons & Add Saved Gems View

#### [MODIFY] user_profile_page.dart
- Fix "Personalized Maps" `onTap: () {}` → navigate to a saved gems view or show a list
- Add a dedicated "Saved Pins" section that shows real `user.savedGems` from Firestore, not just contributions
- Ensure profile avatar upload works (already has `_updateAvatar` - verify `MediaService.uploadProfilePicture` is wired to Firebase Storage)
- Add AppBar consistently

### 3. Share Hidden Gem Screen — Fix Image Upload & App Bar

#### [MODIFY] share_hidden_gem_initial_page.dart
- The app bar is a custom container (not a proper `AppBar`). Keep it but verify it has the proper back button and branding
- The media removal from the list calls `provider.notifyListeners()` but it's commented out — fix this
- Verify `publishToCommunity` actually uploads to Firebase Storage (it calls `_mediaService.uploadGemImage` — verify this method exists and works)

### 4. Explore Page — Fix App Bar & Filter Sheet

#### [MODIFY] explore_page_with_notif_screen.dart  
- The top overlay "app bar" uses `Container` with height 56. Make sure it shows the user avatar (from Firestore), not a hardcoded black circle
- The filter sheet `_showFilterSheet` must actually apply all filter states to the gem list (check if it's connected to `_superUserOnly`, categories, vibe)
- Fix `_buildBackgroundRadar()` radar button if it exists

### 5. Settings Page — Complete All Stub Implementations

#### [MODIFY] settings_page.dart
- "Push Notifications" `onTap: () {}` → navigate to `AppRoutes.notificationSettingsScreen`
- "Help Center" → show a real dialog or web URL
- "Terms & Privacy Policy" → show a bottom sheet or navigate

### 6. All Screens — Consistent AppBar Pattern

All screens that are missing consistent app bars will receive a proper `AppBar` or a consistent top bar widget:
- `settings_page.dart` — already has top bar (good)
- `leaderboard_screen.dart` — check
- `admin_dashboard_screen` — check
- `super_user_dashboard_screen` — check
- `place_details_screen` — check
- `chat_details_screen` — check

### 7. Maps Page — Real Pins Logic

#### [MODIFY] maps_page.dart
The `_buildPinsCard` must:
1. Read `user.savedGems.length` from `UserProvider`
2. Compute limit: 10 for Free, 100 for Pro, unlimited for SuperUser
3. Show real progress bar: `savedGems.length / limit`
4. Show actual count: "X of Y pins used"

### 8. MediaService — Verify Upload Works

#### [MODIFY] media_service.dart (if needed)
Verify `uploadProfilePicture` and `uploadGemImage` actually upload to Firebase Storage (not local only).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to catch any compile errors introduced
- Run `flutter run` and manually test all flows

### Manual Verification
1. Profile → tap camera icon → select image → verify it appears in profile and in Firestore `avatarUrl`
2. Share Gem → pick image → fill form → publish → verify it appears in Firestore `gems` collection
3. Maps page → verify pin count shows real saved gem count from Firestore
4. Explore → search → verify results filter correctly
5. Settings → tap each item → verify all buttons do something meaningful
6. All pages → verify consistent app bars are visible

## Open Questions

> [!IMPORTANT]
> 1. Should the "Personalized Maps" section in profile navigate to a new "My Saved Gems" page, or show an inline list?
> 2. For the `gem.category` vs location label: should we show coordinates, address from reverse geocoding, or just category label?
> 3. For "Help Center" and "Terms & Privacy" — should these open a URL (if so, what URL?) or show a placeholder dialog?
