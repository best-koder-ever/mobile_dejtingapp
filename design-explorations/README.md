# Design Explorations

This folder stores AI-generated design variants from Google Stitch, organized for easy comparison and tracking.

## Quick Start

**Browse designs visually:**
```bash
cd design-explorations/stitch-designs/profile-card/variant-01-coral
open preview.png          # View screenshot
open design.html          # View interactive HTML
cat metadata.yaml         # See details
```

**Generate new design with Stitch:**
1. Ask AI: "Generate a [screen name] design for DatingApp"
2. Stitch creates HTML + screenshot
3. Save to: `stitch-designs/[component]/variant-[NN]-[theme]/`
4. Add `metadata.yaml` with user stories and notes

## What's Here

### 📁 stitch-designs/
AI-generated designs organized by component.

**Example:**
```
profile-card/
  variant-01-coral/        ← Production design (IMPLEMENTED)
    design.html           ← Interactive Stitch HTML
    preview.png           ← Screenshot for quick reference
    metadata.yaml         ← User stories, status, notes
  variant-02-purple/       ← Alternative theme (exploring)
  variant-03-minimal/      ← Cleaner variant (planned)
```

### 📁 theme-variants/
Cross-component theme studies (colors, typography).

### 📁 competitive-research/
Screenshots from Hinge, Bumble, Tinder for inspiration.

## How This Helps

### Problem: Where do Stitch designs go?
**Before:** Scattered in /tmp/, Downloads, lost after a day  
**After:** Organized by component + variant, permanently stored

### Problem: Which design is for which feature?
**Before:** Unclear which screens use which designs  
**After:** `metadata.yaml` lists user stories (US1, US2, US4) and Flutter screens

### Problem: Forgot why we chose this design?
**Before:** Design decisions lost, have to re-discuss  
**After:** `metadata.yaml` documents strengths, concerns, alternatives

### Problem: Want to try different themes?
**Before:** Regenerate from scratch, lose previous work  
**After:** Multiple variants side-by-side (variant-01-coral, variant-02-purple)

## Example: ProfileCard

**Component:** ProfileCard  
**Variants:** 3 (coral, purple, minimal)  
**Used in:** US1 (onboarding), US2 (discovery), US4 (safety)  
**Status:** variant-01 IMPLEMENTED ✅

Open the files:
```bash
# See the implemented design
open design-explorations/stitch-designs/profile-card/variant-01-coral/preview.png

# Read why we chose this
cat design-explorations/stitch-designs/profile-card/variant-01-coral/metadata.yaml

# View interactive HTML
open design-explorations/stitch-designs/profile-card/variant-01-coral/design.html
```

## Workflow

### 1. Generate Design (with Stitch MCP)
Ask AI: "Generate a match celebration screen"
→ Stitch creates HTML + screenshot

### 2. Save Design
```bash
# Create variant folder
mkdir -p design-explorations/stitch-designs/match-celebration/variant-01-confetti

# Save files
mv Downloads/stitch-design.html design-explorations/.../design.html
curl [screenshot-url] > .../preview.png
```

### 3. Document Design
Create `metadata.yaml`:
```yaml
component: match-celebration
variant: variant-01-confetti
user_stories: [US2]
screens: [lib/matches_screen.dart]
status: exploring
notes: |
  Celebration screen when two users match.
  Features confetti animation, profile photos, "It's a Match!" text
```

### 4. Implement in Flutter
- Reference design while coding
- Update metadata: `implementation_status: complete`
- Add path: `flutter_widget_path: lib/widgets/match_celebration.dart`

## Finding What You Need

**"I'm working on US2 (Discovery), what designs exist?"**  
→ Search metadata.yaml files for `user_stories: [US2]`

**"We have 3 ProfileCard variants, which is production?"**  
→ Look for `status: implemented` in metadata.yaml

**"What design decisions did we make?"**  
→ Read `notes`, `strengths`, `concerns` in metadata.yaml

**"I want to try a purple theme across all components"**  
→ Generate variant-*-purple for each component

## Current Inventory

| Component | Variants | Status | Used in |
|-----------|----------|--------|---------|
| ProfileCard | 1 | ✅ Implemented | US1, US2, US4 |
| MatchCelebration | 0 | 📋 Planned | US2 |
| ChatInterface | 0 | 📋 Planned | US3 |
| OnboardingWizard | 0 | 📋 Planned | US1 |

## Next Steps

**Priority designs to generate:**
1. MatchCelebration (US2) - "It's a Match!" screen
2. ChatInterface (US3) - Messaging layout
3. FilterSettings (US2) - Age/distance preferences

Just ask AI: "Generate a [component name] design for DatingApp"
