# DejTing App - Complete Screen Map

**Design System:** Coral Light Theme  
**Project:** Google Stitch MCP (ID: 8469203751545122197)  
**Status:** All 15 screens complete ✅  
**Last Updated:** February 4, 2026

---

## 📊 Overview

This document maps all screens to user stories, shows implementation status, and provides design links.

### Quick Stats
- **Total Screens:** 15
- **User Stories Covered:** 4 (US1-US4)
- **Design Variants:** 1 primary (variant-01-coral), 1 special (variant-02-animated for Match Celebration)
- **Completion:** 100%
- **Design Tool:** Google Stitch MCP + Gemini 3 Flash

---

## 🎨 Design System

### Colors
- **Primary:** #7f13ec (Purple)
- **Accent:** #FF7F50 (Coral)
- **Gradient:** Coral-to-Purple (hero sections, CTAs)
- **Success:** #34C759 (green for verified badges)
- **Warning:** #FF9500 (orange for reports)
- **Error:** #FF3B30 (red for blocks/delete)

### Typography
- **Font Family:** Plus Jakarta Sans
- **Scale:** Material Design type scale
- **Weights:** Regular (400), Medium (500), Bold (700)

### Spacing & Layout
- **Grid:** Material Design 8pt grid
- **Border Radius:** 16px (full roundness)
- **Elevation:** Material Design 3 shadows
- **Saturation:** Level 2 (vibrant)

---

## 📱 Screen Catalog

### US1: Profile Creation (Onboarding)

| # | Screen | Component | Preview | User Stories | Status | Notes |
|---|--------|-----------|---------|--------------|--------|-------|
| 1 | Welcome Screen | `welcome-screen` | [preview.png](stitch-designs/welcome-screen/variant-01-coral/preview.png) | US1 | ✅ Design Complete | Coral-to-purple gradient, app branding, email CTA |
| 2 | Wizard: Basic Info | `wizard-basic-info` | [preview.png](stitch-designs/wizard-basic-info/variant-01-coral/preview.png) | US1 | ✅ Design Complete | Step 1/3: Name, birthday, gender, location |
| 3 | Wizard: Preferences | `wizard-preferences` | [preview.png](stitch-designs/wizard-preferences/variant-01-coral/preview.png) | US1 | ✅ Design Complete | Step 2/3: Age/distance sliders, interests |
| 4 | Wizard: Photos | `wizard-photos` | [preview.png](stitch-designs/wizard-photos/variant-01-coral/preview.png) | US1 | ✅ Design Complete | Step 3/3: 2x3 grid, blur controls |
| 5 | Profile Complete | `profile-complete` | [preview.png](stitch-designs/profile-complete/variant-01-coral/preview.png) | US1 | ✅ Design Complete | Celebration with confetti, preview card |

### US2: Discovery & Matching

| # | Screen | Component | Preview | User Stories | Status | Notes |
|---|--------|-----------|---------|--------------|--------|-------|
| 6 | Discover Feed | `discover-feed` | [preview.png](stitch-designs/discover-feed/variant-01-coral/preview.png) | US2 | ✅ Design Complete | Card stack, 5 actions, match badge |
| 7 | Match Celebration | `match-celebration` | [preview.png](stitch-designs/match-celebration/variant-02-animated/preview.png) | US2 | ✅ Design Complete - v2 | Vibrant gradient mesh, confetti (v1 was boring) |
| 8 | Matches List | `matches-list` | [preview.png](stitch-designs/matches-list/variant-01-coral/preview.png) | US2 | ✅ Design Complete | 2-column grid, NEW badges, tabs |

### US3: Messaging

| # | Screen | Component | Preview | User Stories | Status | Notes |
|---|--------|-----------|---------|--------------|--------|-------|
| 9 | Conversation List | `conversation-list` | [preview.png](stitch-designs/conversation-list/variant-01-coral/preview.png) | US3 | ✅ Design Complete | Vertical list, typing indicators, swipe actions |
| 10 | Ice Breaker Library | `ice-breaker-library` | [preview.png](stitch-designs/ice-breaker-library/variant-01-coral/preview.png) | US3 | ✅ Design Complete | 6 categories with unique gradients |

### US4: Safety & Privacy

| # | Screen | Component | Preview | User Stories | Status | Notes |
|---|--------|-----------|---------|--------------|--------|-------|
| 11 | Privacy Settings | `privacy-settings` | [preview.png](stitch-designs/privacy-settings/variant-01-coral/preview.png) | US4 | ✅ Design Complete | 4 sections, blur controls, BETA features |
| 12 | Block/Report Modal | `block-report-modal` | [preview.png](stitch-designs/block-report-modal/variant-01-coral/preview.png) | US4 | ✅ Design Complete | Bottom sheet, reason chips, red theme |
| 13 | Blocked Users List | `blocked-users-list` | [preview.png](stitch-designs/blocked-users-list/variant-01-coral/preview.png) | US4 | ✅ Design Complete | Grayscale photos, unblock buttons |

### Additional Screens (Bonus)

| # | Screen | Component | Preview | User Stories | Status | Notes |
|---|--------|-----------|---------|--------------|--------|-------|
| 14 | Profile Detail View | `profile-detail-view` | [preview.png](stitch-designs/profile-detail-view/variant-01-coral/preview.png) | US2, US4 | ✅ Design Complete | Photo gallery, bio, interests, match insights |
| 15 | Account Settings | `account-settings` | [preview.png](stitch-designs/account-settings/variant-01-coral/preview.png) | US1, US4 | ✅ Design Complete | 8 sections: account, discovery, privacy, premium |

---

## 🔗 Screen Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    App Launch                               │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
          [1] Welcome Screen
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              Profile Creation Wizard                        │
│  [2] Basic Info → [3] Preferences → [4] Photos → [5] Complete │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
          [6] Discover Feed ──────────┐
                  │                   │
                  ├─ Swipe Right ─────┼──→ [7] Match Celebration
                  │                   │            │
                  │                   │            ▼
                  │                   │    [9] Conversation List
                  │                   │            │
                  │                   │            ▼
                  │                   │    [10] Ice Breaker Library
                  │                   │
                  ├─ View Info ───────┼──→ [14] Profile Detail View
                  │                   │
                  ├─ View Matches ────┼──→ [8] Matches List
                  │                   │
                  └─ Settings ────────┼──→ [15] Account Settings
                                      │            │
                                      │            ▼
                                      │    [11] Privacy Settings
                                      │            │
                                      │            ▼
                                      │    [13] Blocked Users List
                                      │
                                      └──→ [12] Block/Report Modal
                                           (from any profile view)
```

---

## 📋 User Story Coverage

### US1: Profile Creation & Management
**Goal:** Allow users to create and manage comprehensive profiles with photos and privacy controls.

**Screens:**
1. Welcome Screen - First impression, login
2. Wizard: Basic Info - Core demographics
3. Wizard: Preferences - Match criteria
4. Wizard: Photos - Visual identity
5. Profile Complete - Success celebration
15. Account Settings - Edit profile, app settings

**Coverage:** ✅ 100% (6 screens)

---

### US2: Discovery & Matching
**Goal:** Enable users to discover potential matches, view profiles, and celebrate mutual matches.

**Screens:**
6. Discover Feed - Main swipe interface
7. Match Celebration - Mutual like notification
8. Matches List - See all matches
14. Profile Detail View - Deep dive into profiles

**Coverage:** ✅ 100% (4 screens)

---

### US3: Messaging & Ice Breakers
**Goal:** Facilitate meaningful conversations with conversation starters.

**Screens:**
9. Conversation List - All active chats
10. Ice Breaker Library - Conversation starters

**Coverage:** ✅ 100% (2 screens)

---

### US4: Safety & Privacy
**Goal:** Empower users with safety tools and privacy controls.

**Screens:**
11. Privacy Settings - Photo blur, visibility controls
12. Block/Report Modal - Report/block users
13. Blocked Users List - Manage blocks

**Coverage:** ✅ 100% (3 screens)

---

## 🚀 Implementation Roadmap

### Phase 1: Core Flow (MVP) - Priority 1
Screens needed for basic user journey:
- [x] Welcome Screen (1)
- [x] Wizard: Basic Info, Preferences, Photos (2, 3, 4)
- [x] Profile Complete (5)
- [x] Discover Feed (6)
- [x] Match Celebration (7)
- [x] Conversation List (9)

**Status:** All designs complete ✅  
**Next Step:** Flutter implementation

### Phase 2: Enhanced Discovery - Priority 2
- [x] Matches List (8)
- [x] Profile Detail View (14)
- [x] Ice Breaker Library (10)

**Status:** All designs complete ✅

### Phase 3: Safety & Settings - Priority 3
- [x] Privacy Settings (11)
- [x] Block/Report Modal (12)
- [x] Blocked Users List (13)
- [x] Account Settings (15)

**Status:** All designs complete ✅

---

## 🎯 Design Highlights

### Best Screens (High Quality)
1. **Match Celebration v2** - Dramatic improvement from v1, vibrant gradient mesh with confetti
2. **Ice Breaker Library** - 6 unique gradients per category, visually rich
3. **Privacy Settings** - Comprehensive 4-section layout with nested controls
4. **Profile Detail View** - Photo gallery with match insights
5. **Discover Feed** - Card stack with smooth depth perception

### Innovative Features
- **Photo Blur Privacy** (Wizard Photos, Privacy Settings) - Slider control with live preview
- **Match Insights** (Profile Detail View) - AI-generated compatibility reasons
- **Ice Breaker Categories** (Ice Breaker Library) - 6 themed gradients reduce messaging anxiety
- **Screenshot Protection BETA** (Privacy Settings) - Cutting-edge safety feature
- **Conversation Prompts** (from Feb 3 session) - Mutual question feature (variant-03)

### Design System Achievements
- ✅ Consistent coral/purple theme across all 15 screens
- ✅ Plus Jakarta Sans typography throughout
- ✅ Material Design 3 spacing and elevation
- ✅ Accessible color contrast ratios
- ✅ Mobile-first responsive design

---

## 📖 Documentation Links

- **Generation Plan:** [STITCH_SCREEN_PLAN.md](STITCH_SCREEN_PLAN.md)
- **Stitch Project:** https://stitch.withgoogle.com/projects/8469203751545122197
- **User Stories:** `/home/m/development/DatingApp/specs/001-mvp-foundation/`
- **Flutter App:** `/home/m/development/mobile-apps/flutter/dejtingapp/`

---

## 🔍 Search by Feature

### Photo Management
- Wizard: Photos (4) - Upload with privacy
- Privacy Settings (11) - Blur controls
- Profile Detail View (14) - Gallery viewer

### Messaging
- Conversation List (9) - All chats
- Ice Breaker Library (10) - Starters
- Match Celebration (7) - Send message CTA

### Safety
- Privacy Settings (11) - Visibility controls
- Block/Report Modal (12) - Report users
- Blocked Users List (13) - Manage blocks

### Settings
- Account Settings (15) - Comprehensive hub
- Privacy Settings (11) - Safety settings

### Discovery
- Discover Feed (6) - Main swipe
- Matches List (8) - All matches
- Profile Detail View (14) - Full profile
- Match Celebration (7) - Mutual like

---

## 📝 Notes

### Generation Process
- **Tool:** Google Stitch MCP with Gemini 3 Flash model
- **Date:** February 4, 2026
- **Duration:** ~2.5 hours for 15 screens
- **Issues:** 2 API intermittent errors, both recovered successfully
- **Success Rate:** 100% (15/15 screens generated)

### Design Decisions
1. **Match Celebration v2:** Replaced "boring" v1 with vibrant gradient mesh after user feedback
2. **Ice Breaker Gradients:** Each category has unique gradient to aid visual scanning
3. **Privacy Focus:** Blur controls prominent in wizard and settings
4. **Red Theme for Safety:** Block/Report modal uses red (#ec1313) for destructive actions
5. **Grayscale Blocked Users:** Desaturated photos visually indicate blocked status

### Future Enhancements (Not Yet Designed)
- Profile Editor (full bio/photo/preferences editor)
- Premium Plans screen (subscription comparison)
- Delete Account flow (confirmation + survey)
- Empty states collection (no matches, daily limit, etc.)
- Notification settings detail screen
- Help Center / Support Chat

---

**End of Screen Map**  
Generated automatically on February 4, 2026
