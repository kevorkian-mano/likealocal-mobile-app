# LikeALocal - Report

> **Experience the city like a local.**

---

## Project Overview
- **Course:** Software Mobile Development
- **Semester:** Spring 2026
- **Instructor:** Dr. Milad Ghantous
- **TAs:** Donia Ali, Amr Samir
- **Deadline:** April 16, 2026
- **Team:** Eyad and Payroll

### Team Members
| Name | Student ID | Email | Lab |
| :--- | :--- | :--- | :--- |
| Eyad Ahmed | 13005238 | eyad.elmaleh@student.giu-uni.de | P24 |
| Manuel Youssef | 13006600 | manuel.kevorkian@student.giu-uni.de | P21 |
| Chantal Sheriff | 13007034 | chantal.andrawes@student.giu-uni.de | P21 |
| Ebram Nageh | 13006318 | ebram.attia@student.giu-uni.de | P25 |
| Youstina Raouf | 13001755 | youstina.boutrous@student.giu-uni.de | P21 |

---

## 1. Project Vision & Idea
**LikeALocal** is a premium mobile experience designed to bridge the gap between sightseeing and soul-searching. In a world characterized by over-tourism, travelers often miss the true essence of a city—the hidden jazz bar, the family-run eatery, or the quiet rooftop with a view only locals know.

The application empowers users to discover curated "Hidden Gems" through a rich, interactive map and personalized feed. Users can contribute their own discoveries, engage with the community via a specialized chat system, and rise to the status of a "Super User" through high-value engagement.

---

## 2. Aesthetic & UI/UX Strategy
To ensure the application "stands out" among academic submissions, we have adopted an **Organic Discovery** aesthetic. This direction moves away from generic travel UI in favors of a premium, grounded experience.

### Visual Identity
- **Color Palette**: A sophisticated "Midnight Pine" palette featuring Deep Forest greens (#3E5641) and Midnight Pine headers (#0B1E19) to evoke a sense of exploration and authenticity.
- **Typography**: We utilize **Outfit** for bold, modern headings and **Inter** for high-legibility body text, ensuring a smooth reading experience under varying light conditions during travel.
- **UI Patterns**: The app employs Glassmorphism for map overlays, allowing users to interact with UI components without losing their spatial context on the interactive map.

---

## 3. User Roles & Permissions
The application defines five distinct user roles, each with a specific set of permissions and capabilities. The roles are hierarchical in terms of access and trust.

- **Guest** (Unauthenticated Visitor): Automatically assigned upon first app launch. Guests can view the map, read basic place descriptions, and view pricing but cannot save places, set reminders, or participate in social/contribution flows.
- **Registered User** (Free Tier): Base authenticated role. Can complete the "Vibe Picker" quiz, create a profile, save pins (limit 3), set reminders (limit 1), and contribute content (subject to admin approval).
- **Premium User** (Paid Tier): Unlocks all usage limitations. Unlimited pins, unlimited reminders, access to the AI Trip Planner, and offline neighborhood map downloads.
- **Super User** (Local Legend): Earned via high reputation scores. Benefits from instant publishing (bypassing admin moderation), content boosting in search results, and access to a dedicated Super User Dashboard with AI-powered suggested replies.
- **Admin** (System Administrator): Backend operational role. Responsible for content moderation, payment verification, user management, and platform-wide analytics monitoring.

---

## 4. UI/UX High-Fidelity Mockups
*The high-fidelity design of the LikeALocal application adheres to the "Organic Discovery" aesthetic. Mockups include:*
- **Landing Page**
- **Sign In & Sign Up Pages**
- **Explore Feed & Interactive Map**
- **Notification Layer & Map Interaction**
- **Place Details, Add Place, & P2P Chat**
- **AI Bot & User Profile**
- **Settings & Spatial Search**

---

## 5. Sequence Diagram Logic
- **Phase 0:** Guest Entry [DONE]
- **Phase 1:** Registration & Vibe Scoring [DONE]
- **Phase 2:** Geolocation [DONE]
- **Phase 3:** Deep-dive Interaction [DONE]
- **Phase 4:** Multi-Stage Contribution [DONE]
- **Phase 5:** Secure P2P communication [DONE]
- **Phase 6:** AI-Personalized Chat [DONE]
- **Phase 7:** Reputation System [DONE]
- **Phase 8:** Proximity Geofencing [DONE]
- **Phase 9:** Offline Architecture [DONE]
- **Phase 10:** Manual Verification [DONE]
- **Phase 11:** Admin Moderation [DONE]
- **Phase 12:** Super User Impact Dashboard [DONE]

---


## 6. User Stories

### Phase 0: Landing & Guest Exploration
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR0-1 | Guest | Arrive at a visually engaging home screen immediately understand the app's purpose. | Good UI/UX |
| FR0-2 | Guest | Tap a pin to view place description and photos to assess content before account creation. | Rich UI |
| FR0-3 | Guest | Use basic "Near Me" and search to verify coverage in the current location. | Near me feature |
| FR0-4 | Guest | See clear explanation of limited features in guest mode to understand value of signing up. | Monetization |
| FR0-5 | Guest | View pricing plans and premium features to evaluate future upgrade. | Monetization |
| FR0-6 | Guest | Read overview of community and AI approach to understand the app's uniqueness. | AI context |
| FR0-7 | Guest | Prompted to sign up only on restricted actions to ensure frictionless conversion. | User accounts |
| FR0-8 | Guest | [Standout] View visual indicator of "hidden gem density" to identify interesting neighborhoods. | Visual Discovery |

### Phase 1: Authentication & Onboarding
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR1-1 | New User | Create account via Email/Password or Google Sign-In for secure access. | Auth |
| FR1-2 | New User | Receive email verification to secure account and enable recovery. | Firebase Auth |
| FR1-3 | New User | See helpful error messages for registration failures to correct issues easily. | Error Handling |
| FR1-4 | Returning User | Log in using existing credentials to resume app use without re-entering info. | Auth |
| FR1-5 | Registered User | Log out to protect personal data on shared devices. | Security |
| FR1-6 | Registered User | Request password reset email if credentials are forgotten. | Firebase Auth |
| FR1-7 | New User | Complete interactive preference activity (Vibe Picker) for AI initialization. | AI learning |
| FR1-8 | New User | Skip preference activity to start exploring immediately. | Good UX |
| FR1-9 | New User | See summary of inferred preferences to confirm AI understanding. | AI component |
| FR1-10 | Registered User | Upload profile picture and edit bio so others recognize contributions. | User accounts |
| FR1-11 | Registered User | Update profile information anytime from settings. | User accounts |
| FR1-12 | Registered User | Permanently delete account and all data after confirming intent. | Privacy/GDPR |
| FR1-13 | New User | See Premium benefits introduction during onboarding (dismissible). | Monetization |

### Phase 2: Discovery & Exploration
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR2-1 | Registered User | View map centered on current GPS location. | "Near me" feature |
| FR2-2 | Registered User | See interactive markers on map that can be tapped to preview info. | Map pins |
| FR2-3 | Registered User | Browse list of nearby places that updates as map moves. | Discovery |
| FR2-4 | Registered User | Search for places by name or specific dish (e.g., "Koshary"). | Search |
| FR2-5 | Registered User | Filter map/list by Category and Vibe. | Filtering |
| FR2-6 | Registered User | Activate "Near Me" control to re-center map and refresh list. | Near me feature |
| FR2-7 | Registered User | [Standout] See trending pins with visual emphasis to spot popular spots. | Social visual |
| FR2-8 | Registered User | [Standout] Filter map to show only Super User recommendations. | Trust filter |
| FR2-9 | Registered User | [Standout] Use interactive control for simultaneous price/vibe filtering. | Adv. filtering |
| FR2-10 | Registered User | [Standout] Trigger "Surprise Me" action for random hidden gems. | Serendipity |
| FR2-11 | Registered User | [Out-of-Scope] Search for places using voice input. | Voice Search |
| FR2-12 | Registered User | [Out-of-Scope] Shake device to fly map to random recommended place. | Shake gesture |

### Phase 3: Place Detail & Interaction
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR3-1 | Registered User | View gallery of images and videos to gauge atmosphere. | Rich UI |
| FR3-2 | Registered User | Read full description written by the contributor. | Writing desc. |
| FR3-3 | Registered User | Read "Local's Tip" section for insider advice. | Local tips |
| FR3-4 | Registered User | View list of recommended dishes specific to the place. | Rec. dishes |
| FR3-5 | Registered User | Save (pin) place to personal collection for later. | Pin for later |
| FR3-6 | Free User | Notified when reaching pin limit with upgrade path info. | Monetization |
| FR3-7 | Registered User | Set reminder to notify when physically near the place. | Loc. reminders |
| FR3-8 | Registered User | Submit star rating and write text review after visiting. | Reviews |
| FR3-9 | Registered User | Edit or delete my previously written review/rating. | Review control |
| FR3-10 | Registered User | See AI-generated summary highlighting common review themes. | Smart suggestions |
| FR3-11 | Registered User | [Standout] Express sentiment using low-effort emoji reactions. | Interaction |
| FR3-12 | Registered User | See list of other nearby places with similar vibe. | Rec. engine |
| FR3-13 | Registered User | Share summary with image and local tip to other apps. | Sharing |
| FR3-14 | Registered User | [Standout] See estimate of busy times based on community data. | Analytics |
| FR3-15 | Registered User | [Standout] Mark a specific dish as "Must Try" for future reference. | Dish list |
| FR3-16 | Super User | [Standout] View engagement metrics (views/saves) for my places. | Contributor analytics |
| FR3-17 | Registered User | [Out-of-Scope] Listen to local tips via text-to-speech. | TTS Feature |

### Phase 4: Contribution & Content Creation
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR4-1 | Registered User | Add a brand new place to the map. | Add places |
| FR4-2 | Registered User | Upload media from device gallery or camera. | Media upload |
| FR4-3 | Registered User | App automatically suggests tags and category for photo using AI. | AI external API |
| FR4-4 | Registered User | Enter name, category, and set map location. | Content creation |
| FR4-5 | Registered User | Write descriptive overview for other users. | Writing desc. |
| FR4-6 | Registered User | Provide a "Secret Tip" or insider knowledge. | Local tips |
| FR4-7 | Registered User | Specify one or more recommended dishes. | Rec. dishes |
| FR4-8 | Registered User | Edit details of a contributed place if info changes. | Content control |
| FR4-9 | Registered User | Delete a place contributed in error or if permanently closed. | Content control |
| FR4-10 | Registered User | See current approval status (pending, approved, rejected). | Moderation trans. |
| FR4-11 | Super User | Places bypass moderation and appear immediately with trust badge. | Super user benefit |
| FR4-12 | Registered User | Report inaccurate or outdated place listings. | Quality control |
| FR4-13 | Registered User | [Standout] Save incomplete place submission as draft. | Draft saving |
| FR4-14 | Registered User | [Standout] Track contribution streaks displayed on profile. | Gamification |
| FR4-15 | Registered User | [Standout] Earn recognition badges for contribution milestones. | Gamification |

### Phase 5: Social & Communication System
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR5-1 | Registered User | Initiate private chat with post owner for personalized advice. | Chat system |
| FR5-2 | Post Owner | Enable or disable chatting with privacy toggle. | Privacy modes |
| FR5-3 | Post Owner | Define daily DND schedule for chat availability. | Scheduling |
| FR5-4 | Registered User | See indication on post if owner is currently unavailable. | Good UX |
| FR5-5 | Registered User | Report inappropriate chat or block a specific user. | Safety/Moderation |
| FR5-6 | Super User | [Standout] Access AI-generated suggested replies for chat. | AI for power users |

### Phase 6: AI Personalization & Smart Assistant
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR6-1 | Registered User | System remembers behavior to improve recommendation relevance. | Learning user style |
| FR6-2 | Registered User | Interact with AI chatbot for complex natural language queries. | AI chatbot |
| FR6-3 | Registered User | Chatbot responses include actionable place suggestions. | Rec. engine |
| FR6-4 | Registered User | Ask chatbot for taste-based "Surprise Me" recommendation. | AI discovery |
| FR6-5 | Registered User | AI considers typical budget and atmosphere preferences. | Feature personalization |
| FR6-6 | Registered User | [Standout] AI proactively suggests personalized daily itineraries. | Trip planning |

### Phase 7: Reputation & Super User System
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR7-1 | Registered User | See visual "Local Legend" badge on trusted contributor profiles. | Reputation visual |
| FR7-2 | Registered User | reputation score calculated based on contributions and helpfulness. | Super user logic |
| FR7-3 | Registered User | Attain Super User status when reputation threshold is crossed. | Role achievement |
| FR7-4 | Super User | Contributions appear with higher priority in search. | Algorithm boost |
| FR7-5 | Registered User | Filter to view only Super User recommendations. | Trust filter |
| FR7-6 | Super User | [Standout] Access dashboard with reputation breakdown and impact. | Analytics |

### Phase 8: Notifications & Background Triggers
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR8-1 | Registered User | Receive push notification when near a saved gem or recommendation. | Background triggers |
| FR8-2 | Registered User | Tap notification to deep-link directly to place detail view. | Navigation |
| FR8-3 | Registered User | Receive push notification for chat replies or comments. | Active push |
| FR8-4 | Registered User | Control notification categories through settings. | User control |
| FR8-5 | Super User | [Standout] Receive weekly contribution impact summary. | Retention |

### Phase 9: Offline Capability & Caching
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR9-1 | Registered User | Display previously viewed info without internet connection. | Caching |
| FR9-2 | Registered User | Save pin while offline; syncs automatically when online. | Offline contrib. |
| FR9-3 | Registered User | Clear indicator when operating offline to explain limited features. | Error Handling |
| FR9-4 | Premium User | [Standout] Download neighborhood maps for full offline use. | Offline packs |

### Phase 10: Monetization & Premium Features
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR10-1 | Free User | Save limited number of pins and reminders at no cost. | Usage limits |
| FR10-2 | Free User | Informative prompt on limit reach explaining Premium benefits. | Conversion flow |
| FR10-3 | Premium User | Unlock unlimited pins and location reminders. | Paid features |
| FR10-4 | Premium User | Access to advanced AI personalized itinerary generation. | Add. paid feature |
| FR10-5 | Premium User | Download neighborhood data for complete offline access. | Add. paid feature |
| FR10-6 | User | Upgrade via local payment methods (manual reference check). | Local adaptation |

### Phase 11: Admin Dashboard & Moderation
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR11-1 | Admin | Access secure, separate administration area. | Role access |
| FR11-2 | Admin | View dashboard summarizing platform health metrics. | Admin analytics |
| FR11-3 | Admin | Review and moderate new place submissions. | Content moderation |
| FR11-4 | Admin | Manage reported content queue and take corrective actions. | Safety enforcement |
| FR11-5 | Admin | Manually activate Premium status after verifying payment reference. | Payment ops |
| FR11-6 | Admin | Search and ban users or manually grant statuses. | User management |
| FR11-7 | Admin | Broadcast push notifications to all users or segments. | Admin communication |

### Phase 12: Super User Dashboard
| ID | Role | User Story | Mapping |
| :--- | :--- | :--- | :--- |
| FR12-1 | Super User | Access dedicated dashboard hidden from regular users. | Recognition |
| FR12-2 | Super User | See detailed reputation score breakdown. | Metrics transparency |
| FR12-3 | Super User | View engagement analytics for contributed places. | Impact data |
| FR12-4 | Super User | View pending chat requests from travelers for prompt help. | Community engagement |
| FR12-5 | Super User | [Standout] Ability to boost one's own contributions temporarily. | Boosting feature |

---

## 7. Monetization Strategy
To ensure sustainability while remaining accessible, we utilize a **Tiered Constraint** model tailored for the Egyptian market.

- **Free Tier**: Provides full discovery access. Users are limited to **3 saved pins** and **1 location reminder** to encourage account value testing.
- **Premium Tier**: A one-time or subscription-based upgrade unlocking unlimited pins, background proximity alerts, and the AI Trip Planner.
- **Local Payment Integration**: Recognizing the low credit card penetration in Egypt, we support **Direct Wallet Transfers** (InstaPay/Telda/Vodafone Cash) via manual admin verification, as defined in our Phase 10 requirements.

---

## 8. Standing Out: Advanced Components

### AI Component: The Local Lens Assistant
Integrating the **Google Gemini API**, our AI component learns the unique style of each traveler.
- **Adaptive Itineraries**: Custom suggestions based on budget, atmosphere, and history.
- **Contextual Chatbot**: Real-time natural language interaction to find the perfect spot on the fly.

### Out-of-Scope High-Impact Features
To push the boundaries of the course requirements, we propose:
- **Smart Proximity Notifications**: Background services that trigger context-aware push notifications only when near physically high-value pins.
- **Smart Budget Planner**: Automated cost estimation and personalized trip planning tailored to specific user budget constraints.
- **Group Planning & Shared Itineraries**: Real-time collaborative itinerary building with integrated group voting on potential destinations.

---

## 9. Technology Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Firebase (Firestore, Auth, Storage, Cloud Functions)
- **AI Backend**: Firebase Vertex AI (Gemini 1.5 Flash)
