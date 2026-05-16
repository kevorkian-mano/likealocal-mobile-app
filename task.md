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
