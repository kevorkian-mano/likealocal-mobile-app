# Implementation Plan: Finalizing 10 Partially Implemented Requirements

This document outlines the detailed missing pieces and the implementation plan for the 10 requirements identified as "Partially Implemented".

## Detailed Missing Requirements Analysis

| Story ID | Requirement | Current State (Mocked/Partial) | Missing Detailed Implementation Plan |
|---|---|---|---|
| **FR3-13** | Share summary with image and local tip | Currently, the "Share" button only copies generic text to the clipboard (`Clipboard.setData`). | **Plan:** Add the `share_plus` package. Implement native sharing intents. Pass the gem's name, a generated tip text, and a deep link or image URL so users can natively share via WhatsApp, Twitter, etc. |
| **FR3-14** | See estimate of busy times | The Place Details UI has a placeholder `if (true) // Simulated availability check` and static busy text. | **Plan:** Create a dynamic algorithm that estimates busy times based on the current hour of the day and the gem's category (e.g., Cafes peak in the morning, Dining in the evening). Update the UI to display this dynamically calculated text/graph. |
| **FR3-16** | View engagement metrics for my places | Dashboard charts (Super User dashboard) use hardcoded `toDouble()` values or random inputs for the `fl_chart` graphs. | **Plan:** Bind the `fl_chart` data sets in the Dashboard to real Firestore metrics (e.g., aggregate the actual `saves` and `views` count from the user's `approvedGems`). |
| **FR4-14** | Track contribution streaks | Streak logic exists only loosely or is hardcoded in the user model/UI. | **Plan:** Add `lastContributionDate` and `currentStreak` fields to the Firestore User document. When a new gem is approved, calculate if it's within 24-48 hours of the last contribution. If so, increment streak; otherwise, reset. Display in UI. |
| **FR7-2** | Reputation score calculated from contributions and helpfulness | Reputation score relies on simulated view/save counts or flat additions without a dynamic, multi-factor formula. | **Plan:** Implement a robust formula in `UserProvider`: `Reputation Score = (Approved Gems * 50) + (Total Views * 1) + (Total Saves * 5)`. Run this calculation dynamically based on live gem arrays. |
| **FR7-6** | Access dashboard with reputation breakdown and impact | Same as FR3-16; visual charts rely on mocked `fl_chart` spots. | **Plan:** Map the newly calculated reputation score components (Gems, Views, Saves impact) into the pie/bar charts in the Super User Dashboard. |
| **FR8-1** | Receive push notification near a saved gem | The background geofencing logic is simulated or only triggers immediately rather than on actual coordinate proximity. | **Plan:** Implement `geolocator` proximity checks within the `background_task_service`. Iterate through the user's saved gems list and trigger a `flutter_local_notifications` alert if `distance < 500m`. |
| **FR8-5** | Receive weekly contribution impact summary | Explicitly marked as `// Mocking a weekly summary` in `background_task_service.dart`. | **Plan:** Use `workmanager` to schedule a periodic weekly task. Calculate the user's total views/saves against a stored previous-week snapshot, and push a local notification detailing the week's impact. |
| **FR12-2** | See detailed reputation score breakdown | The Super User view shows fake Y-axis points (`toY: views.toDouble()`). | **Plan:** Replace the fake values in the Super User Dashboard UI with the real dynamic fields calculated in FR7-2. |
| **FR12-3** | View engagement analytics for contributed places | The specific analytics time-series charts use mocked historical data points. | **Plan:** Since we don't store historical timeseries data per gem in Milestone 1, we will map the real cumulative data against artificial historical decay (for visual shape) OR calculate exact aggregates across all user gems to build the chart natively. |

## User Review Required

> [!IMPORTANT]
> **Dependencies:** Implementing FR3-13 requires adding the `share_plus` package.
> **Background Tasks (FR8-5):** Flutter background tasks via `workmanager` can be inconsistent on iOS simulators and some Android devices depending on OS battery optimizations. I will implement it strictly to documentation, but physical device testing is recommended.
> **Historical Data (FR12-3):** We currently only store *cumulative* views/saves, not timestamped views. I will generate the time-series charts by mapping the total cumulative data logically (e.g. splitting total views over the gem's lifespan) so the graphs look realistic and reflect real data accurately.

## Implementation Order
If approved, I will implement these in the following grouped logical order:
1. **Sharing & Detail Logic:** FR3-13 (Share) & FR3-14 (Busy times)
2. **Reputation & Streaks (Logic):** FR4-14 (Streaks) & FR7-2 (Reputation Formula)
3. **Dashboards & Charts (UI mapping):** FR3-16, FR7-6, FR12-2, FR12-3
4. **Background & Notifications:** FR8-1 (Geofencing) & FR8-5 (Weekly task)

Please provide your feedback or approve this plan so I can begin execution.
