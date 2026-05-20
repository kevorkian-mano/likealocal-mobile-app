# Task: Admin Reports Tab Relocation (Immediate Priority)
- [ ] Modify Tab Layout in `AdminUserManagementScreen`
  - [ ] Increase TabController length from 3 to 4 in `initState`
  - [ ] Add the 4th tab `'Community Reports'` (with warning icon `Icons.report_gmailerrorred_outlined`) to `TabBar` in `_buildAppBar`
  - [ ] Add `_buildUserReportsTab(context)` as the 4th child in `TabBarView`
- [ ] Port/Implement Reports UI & Actions
  - [ ] Fetch dynamic reports from Firestore `'alert'` collection (custom `'default'` database)
  - [ ] Implement `_confirmAlertAction` and action buttons (Dismiss, Take Down, Delete Place) with 1-second timeout
  - [ ] Implement `_formatTimestamp` helper method
  - [ ] Ensure elegant styling matching the forest green (#1B3022) theme

# Task Checklist: Implementing Missing Features

- [x] **1. Sharing & Detail Logic**
  - [x] Add `share_plus` dependency
  - [x] Implement native share in `place_details_screen.dart`
  - [x] Implement dynamic busy times calculation in `place_details_screen.dart`
- [x] **2. Reputation & Streaks (Logic)**
  - [x] Update `UserModel` with `lastContributionDate` and `currentStreak` fields
  - [x] Implement streak logic upon gem approval in `admin_moderation` or `user_provider`
  - [x] Implement dynamic reputation formula in `UserProvider`
- [x] **3. Dashboards & Charts (UI mapping)**
  - [x] Bind `fl_chart` in Super User Dashboard to real `views` and `saves`
  - [x] Map real reputation score components to Super User pie/bar charts
- [x] **4. Background & Notifications**
  - [x] Implement `geolocator` proximity checks in `background_task_service.dart` for saved gems
  - [x] Use `workmanager` to schedule a weekly notification for impact summary

# Task: Real-time Proximity Tracking & Database Mismatch Fixes
- [ ] Real-time GPS Location updates
  - [ ] Add `_positionSubscription` to `GemsProvider` and listen to `Geolocator.getPositionStream` when permissions are active
  - [ ] Cancel `_positionSubscription` on provider disposal
- [ ] Smart Fallbacks and Sorting
  - [ ] Refactor `getEffectiveCoordinates(currentUser)` to fallback to the database's collective center of approved gems if currentUser is null or has no contributions/saved gems
  - [ ] Update `approvedGems` sort in `GemsProvider` to sort by proximity using `getEffectiveCoordinates(null)` even when user location is null
  - [ ] Update Explore page `_buildCard` to show distance calculated from `gemsProvider.getEffectiveCoordinates(currentUser)` instead of showing `--- km away`
- [ ] Database Instance Mismatch Fixes (migrate from `FirebaseFirestore.instance` to target the custom `default` database)
  - [ ] Update `background_task_service.dart` geofencing tasks
  - [ ] Update `leaderboard_screen.dart` users list
  - [ ] Update `chat_list_screen.dart` conversations list
  - [ ] Update `manual_payment_screen.dart` payment registrations
  - [ ] Update `notification_service.dart` alerts and reminders checks
  - [ ] Update `user_provider.dart` startup user sync
- [ ] Validation and Verification
  - [ ] Run `flutter analyze` and resolve any compiler errors
  - [ ] Manual test verification of live real-time location stream and dynamic distance re-evaluations
