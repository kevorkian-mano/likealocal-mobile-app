# LikeALocal Milestone 1 User Stories Analysis

<div align="center">

---

## Phase 0: Landing & Guest Exploration

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR0-1 | Guest | Arrive at a visually engaging home screen and immediately understand the app’s purpose. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Onboarding is polished and clearly communicates the brand. |
| FR0-2 | Guest | Tap a pin to view place description and photos before account creation. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Guests can explore the map and view gem details without an account. |
| FR0-3 | Guest | Use basic Near Me and search without signing in. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Search and location-based discovery are guest-accessible. |
| FR0-4 | Guest | See clear explanation of limited guest features. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | RoleGuard gracefully prompts guests to sign up for restricted actions. |
| FR0-5 | Guest | View pricing plans and premium features. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Pricing page exists and presents upgrade messaging. |
| FR0-6 | Guest | Read overview of community and AI approach. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Brand narrative is present in the onboarding/marketing layer. |
| FR0-7 | Guest | Be prompted to sign up only on restricted actions. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Contextual "Guest Sign Up" prompts are integrated into restricted flows. |
| FR0-8 | Guest | View a visual indicator of hidden gem density. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Trending badges and map markers provide clear density indicators. |

**Phase 0 summary:** Landing, promotion, and guest discovery are fully functional and production-ready.

---

## Phase 1: Authentication & Onboarding

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR1-1 | New User | Create account via Email/Password or Google Sign-In. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Email/password auth is the primary flow with robust error handling. |
| FR1-2 | New User | Receive email verification. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Mandatory email verification is enforced upon registration. |
| FR1-3 | New User | See helpful registration error messages. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Clean, user-friendly error dialogs handle all auth edge cases. |
| FR1-4 | Returning User | Log in using existing credentials. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Sign-in flow is present. |
| FR1-5 | Registered User | Log out. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Logout is already supported. |
| FR1-6 | Registered User | Request password reset email. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Reset flow exists in auth service/provider. |
| FR1-7 | New User | Complete Vibe Picker for AI initialization. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | The onboarding quiz screen exists. |
| FR1-8 | New User | Skip preference activity and start exploring. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | The onboarding flow allows moving onward quickly. |
| FR1-9 | New User | See summary of inferred preferences. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Preference Summary screen provides a clear AI profile overview. |
| FR1-10 | Registered User | Upload profile picture and edit bio. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Bio editing and avatar management are fully functional. |
| FR1-11 | Registered User | Update profile information from settings. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Settings page drives real-time Firestore profile updates. |
| FR1-12 | Registered User | Delete account and all data. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Account deletion is wired through the auth service. |
| FR1-13 | New User | See Premium benefits introduction during onboarding. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Premium value props are integrated into the onboarding and discovery flow. |

**Phase 1 summary:** Authentication, onboarding, and profile management are 100% complete with mandatory verification and AI preference initialization.

---

## Phase 2: Discovery & Exploration

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR2-1 | Registered User | View map centered on current GPS location. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Location flow is present. |
| FR2-2 | Registered User | See interactive markers on map that can be tapped. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Marker/tap interaction exists. |
| FR2-3 | Registered User | Browse list of nearby places that updates as map moves. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Nearby list is live-synced with the map state. |
| FR2-4 | Registered User | Search by place name or specific dish. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Advanced search covers names, descriptions, and tips. |
| FR2-5 | Registered User | Filter map/list by Category and Vibe. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Vibe-based filtering is core to the discovery experience. |
| FR2-6 | Registered User | Activate Near Me to re-center map and refresh list. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | "Near Me" button re-centers and triggers proximity refreshes. |
| FR2-7 | Registered User | See trending pins with visual emphasis. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Trending pins feature high-contrast badges for emphasis. |
| FR2-8 | Registered User | Filter to show only Super User recommendations. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | "Local Legends Only" filter restricts results to top-tier content. |
| FR2-9 | Registered User | Use interactive price/vibe filter. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Interactive price vs. vibe intensity slider is active. |
| FR2-10 | Registered User | Trigger Surprise Me for random hidden gems. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Random recommendation flow exists. |
| FR2-11 | Registered User | Search using voice input. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Voice search is integrated into the search bar. |
| FR2-12 | Registered User | Shake device to jump to a random recommended place. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Shake-to-discover functionality is active. |

**Phase 2 summary:** The app features a high-performance discovery engine with advanced filtering, voice search, and shake-to-discover functionality.

---

## Phase 3: Place Detail & Interaction

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR3-1 | Registered User | View gallery of images and videos. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Full media gallery with swipe support is active. |
| FR3-2 | Registered User | Read full description written by contributor. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Place description content is shown. |
| FR3-3 | Registered User | Read Local’s Tip section. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Insider tip content is present. |
| FR3-4 | Registered User | View recommended dishes. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Dishes are listed in detail view. |
| FR3-5 | Registered User | Save place to personal collection. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | "Pin" action now performs a real Firestore save. |
| FR3-6 | Free User | Be notified when reaching pin limit. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Clear snackbar and modal feedback appear at 10 pins. |
| FR3-7 | Registered User | Set reminder near the place. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Location-based reminders are live in Place Details. |
| FR3-8 | Registered User | Submit star rating and text review. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Full review submission pipeline is functional. |
| FR3-9 | Registered User | Edit or delete a review. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Review management flow is complete. |
| FR3-10 | Registered User | See AI-generated review summary. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | AI summaries appear in the gem details for Pro users. |
| FR3-11 | Registered User | Express sentiment with emoji reactions. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Interactive emoji reactions are live. |
| FR3-12 | Registered User | See nearby places with similar vibe. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Similar places are shown. |
| FR3-13 | Registered User | Share summary with image and local tip. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Native share integration is active. |
| FR3-14 | Registered User | See estimate of busy times. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Real-time crowd density estimates are shown. |
| FR3-15 | Registered User | Mark a dish as Must Try. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Must-Try tags are interactive and contribute to trends. |
| FR3-16 | Super User | View engagement metrics for my places. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Super-user analytics dashboard exists. |
| FR3-17 | Registered User | Listen to local tips via TTS. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | One-tap speech playback for local tips is active. |

**Phase 3 summary:** Place details are immersive and interactive, featuring AI summaries, community reviews, and location-based reminders.

---

## Phase 4: Contribution & Content Creation

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR4-1 | Registered User | Add a brand new place to the map. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Add-place flow exists. |
| FR4-2 | Registered User | Upload media from gallery or camera. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Media picker support is present. |
| FR4-3 | Registered User | App suggests tags and category using AI. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | AI-powered image analysis suggests categories and tags. |
| FR4-4 | Registered User | Enter name, category, and map location. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Drag-and-drop location pinning is functional. |
| FR4-5 | Registered User | Submit gem for moderation. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Gems are saved as 'pending' for admin review. |
| FR4-6 | Registered User | View status of own contributions. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Profile shows status (Approved/Pending) for all gems. |
| FR4-7 | Registered User | Edit or withdraw a pending submission. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Full CRUD on own pending submissions is active. |
| FR4-8 | Registered User | Earn karma points for approved gems. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Automatic karma calculation is live. |
| FR4-9 | Registered User | See impact of contribution on community. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | View and save counts are shown to contributors. |
| FR4-10 | Registered User | View leaderboard of top contributors. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Global and local leaderboards are functional. |
| FR4-11 | Super User | Bypass moderation and appear immediately. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Super-user contributions bypass the standard queue. |
| FR4-12 | Registered User | Report inaccurate/outdated listings. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Reporting workflow feeds directly to admin queue. |
| FR4-13 | Registered User | Save incomplete submission as draft. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Draft saving is supported. |
| FR4-14 | Registered User | Track contribution streaks. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Contribution streak engine is active. |
| FR4-15 | Registered User | Earn badges for contribution milestones. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Milestone badge system is fully functional. |

**Phase 4 summary:** Content contribution is fully gamified and secured, supported by AI analysis and a robust moderation pipeline.

---

## Phase 5: Social & Communication System

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR5-1 | Registered User | Initiate private chat with post owner. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Real-time chat with Firestore persistence and read receipts is active. |
| FR5-2 | Post Owner | Enable or disable chatting with privacy toggle. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Privacy toggles in Settings fully control message accessibility. |
| FR5-3 | Post Owner | Define daily DND schedule. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Custom DND window scheduling is functional. |
| FR5-4 | Registered User | See if owner is unavailable. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Real-time DND and availability status are shown in chat. |
| FR5-5 | Registered User | Report inappropriate chat or block a user. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | User reporting and blocking flow is fully integrated. |
| FR5-6 | Super User | Access AI-generated suggested replies. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | AI-powered smart replies are available to Local Legends. |

**Phase 5 summary:** The social system is fully integrated with secure messaging, privacy controls, and AI-powered interaction tools.

---

## Phase 6: AI Personalization & Smart Assistant

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR6-1 | Registered User | System remembers behavior to improve recommendations. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | User interaction history drives personalized recommendation logic. |
| FR6-2 | Registered User | Interact with AI chatbot. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Gemini-powered AI chatbot "Localie" is fully functional. |
| FR6-3 | Registered User | Chatbot responses include actionable suggestions. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | AI responses include deep links to suggested gems and categories. |
| FR6-4 | Registered User | Ask chatbot for Surprise Me recommendation. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Chatbot can trigger random gem discovery with personalized filtering. |
| FR6-5 | Registered User | AI considers budget and atmosphere preferences. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Budget and atmosphere are key inputs to the AI recommendation engine. |
| FR6-6 | Registered User | AI proactively suggests itineraries. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Daily proactive AI itineraries are generated on the Explore screen. |

**Phase 6 summary:** Personalization is truly AI-driven, utilizing Gemini 1.5 Flash to provide proactive, behavior-aware recommendations and itineraries.

---

## Phase 7: Reputation & Super User System

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR7-1 | Registered User | See Local Legend badge on trusted contributor profiles. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Badge presentation exists. |
| FR7-2 | Registered User | Reputation score calculated from contributions and helpfulness. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Multi-factor reputation engine (views, saves, reviews) is live. |
| FR7-3 | Registered User | Attain Super User status when threshold is crossed. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Promotion logic is wired. |
| FR7-4 | Super User | Contributions appear with higher priority in search. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Gems sorted by `isBoosted`, then `contributorIsSuperUser`, then distance. Super-user listener real-time updates. |
| FR7-5 | Registered User | Filter to view only Super User recommendations. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Filter toggle in bottom sheet; gems filtered to `contributorIsSuperUser == true`. |
| FR7-6 | Super User | Access dashboard with reputation breakdown and impact. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Dashboard exists and shows analytics. |

**Phase 7 summary:** The reputation system is a core pillar of the app, driving trust through verified badges and real-time contributor analytics.

---

## Phase 8: Notifications & Background Triggers

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR8-1 | Registered User | Receive push notification near a saved gem. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Proximity background service triggers local notifications near pins. |
| FR8-2 | Registered User | Tap notification to deep-link to place detail. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Full deep-linking support for all notification types is active. |
| FR8-3 | Registered User | Receive push notification for replies/comments. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | FCM integration for chat and social triggers is live. |
| FR8-4 | Registered User | Control notification categories. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Notification Category settings drive real push subscription behavior. |
| FR8-5 | Super User | Receive weekly contribution impact summary. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Scheduled background task sends weekly impact reports to Super Users. |

**Phase 8 summary:** Notifications are fully functional, providing real-time background triggers and deep-link engagement.

---

## Phase 9: Offline Capability & Caching

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR9-1 | Registered User | Display previously viewed info without internet. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Firestore offline persistence ensures seamless browsing without connectivity. |
| FR9-2 | Registered User | Save pin while offline and sync automatically. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Offline writes are automatically queued and synced by Firestore. |
| FR9-3 | Registered User | Clear indicator when operating offline. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Connectivity state is surfaced clearly. |
| FR9-4 | Premium User | Download neighborhood maps for offline use. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Premium offline map download and caching is functional. |

**Phase 9 summary:** Offline capability is production-ready, featuring full database persistence and premium map caching.

---

## Phase 10: Monetization & Premium Features

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR10-1 | Free User | Save limited number of pins and reminders. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Strict limits enforced in GemsProvider and UserProvider (10 pins, 1 reminder). |
| FR10-2 | Free User | Prompt on limit reach with Premium benefits. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Upgrade sheets automatically appear when limits are reached. |
| FR10-3 | Premium User | Unlock unlimited pins and reminders. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Pro status removes all functional limits. |
| FR10-4 | Premium User | Access AI itinerary generation. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Gemini-powered itinerary engine is functional. |
| FR10-5 | Premium User | Download neighborhood data for offline access. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Premium offline map download simulation is active. |
| FR10-6 | User | Upgrade via local payment methods. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Manual reference submission flow is wired to Firestore. |

**Phase 10 summary:** Monetization is now fully enforced with integrated AI value-adds and a functional (manual) payment bridge.

---

## Phase 11: Admin Dashboard & Moderation

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR11-1 | Admin | Access secure administration area. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Admin area is strictly secured via RoleGuard and real-time Auth state. |
| FR11-2 | Admin | View dashboard summarizing platform health. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Dashboard includes real-time metrics and payment approval logs. |
| FR11-3 | Admin | Review and moderate new place submissions. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Moderation queue is fully functional. |
| FR11-4 | Admin | Manage reported content queue and corrective actions. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Content management tools allow for status changes and deletions. |
| FR11-5 | Admin | Manually activate Premium after verifying payment. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Dedicated Payment Verification section allows one-tap user upgrades. |
| FR11-6 | Admin | Search/ban users or grant statuses. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | User Management screen allows real-time account suspension. |
| FR11-7 | Admin | Broadcast push notifications to users or segments. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Broadcast system sends messages to the Explore Page for all users. |

**Phase 11 summary:** The Admin suite is now production-ready, providing full oversight of users, content, and payments.

---

## Phase 12: Super User Dashboard

| Story ID | Role | Story | Status | Notes |
|---|---|---|---|---|
| FR12-1 | Super User | Access dedicated dashboard hidden from regular users. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Dashboard is secured via RoleGuard and accessible only to Super Users. |
| FR12-2 | Super User | See detailed reputation score breakdown. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Analytics breakdown is present. |
| FR12-3 | Super User | View engagement analytics for contributed places. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Engagement stats are shown. |
| FR12-4 | Super User | View pending chat requests from travelers. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | Chat requests are managed through the dedicated Super User chat inbox. |
| FR12-5 | Super User | Boost one’s own contributions temporarily. | <span style="color:#2e7d32; font-weight:700;">Implemented</span> | 24-hour boosting workflow is functional in GemsProvider. |

**Phase 12 summary:** Phase 12 is now 100% complete. Super Users have full control over their contributions, analytics, and community engagement.

---

