# Design System - Long-term Workflow

**Your Persistent, Iterative UI Development System**

## 🎯 What This Gives You

✅ **Persistence**: Everything in Git, never lose work  
✅ **Iteration**: Change once, see everywhere  
✅ **Consistency**: Single source of truth (code = design)  
✅ **Visual Preview**: See all components in isolation  
✅ **No Waste**: Build once, reuse everywhere

---

## 🏗️ Architecture

```
lib/
├── theme/                      ← Design tokens (NEVER changes often)
│   ├── app_theme.dart         ← Colors, fonts, spacing
│   └── spacing.dart           ← 8pt grid system
│
├── widgets/                    ← Reusable components (BUILD HERE)
│   ├── common/                ← Buttons, inputs, cards
│   ├── discovery/             ← Profile cards, swipe UI
│   └── messaging/             ← Chat bubbles, thread lists
│
├── screens/                    ← Full screens (COMPOSE components)
│   ├── discovery_screen.dart  ← Uses ProfileCard widget
│   └── messaging_screen.dart  ← Uses ChatBubble widget
│
└── widgetbook.dart            ← Visual catalog (PREVIEW as you build)
```

---

## 🔄 Your Daily Workflow

### 1. Build Components in Isolation (Widgetbook)

```bash
# Launch your design system catalog
cd /home/m/development/mobile-apps/flutter/dejtingapp
./run-widgetbook.sh

# Opens browser with visual catalog
# You see: Colors, Fonts, Buttons, Cards, etc.
```

**Why this is powerful:**
- See component in ALL states (default, hover, disabled)
- Try different data (short name, long name, no photo)
- No need to navigate to deep screens
- No backend needed to preview UI

### 2. Create a New Component

```dart
// lib/widgets/common/primary_button.dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(label),
    );
  }
}
```

**Add to Widgetbook:**
```dart
// lib/widgetbook.dart (add to Common Components category)
WidgetbookUseCase(
  name: 'Primary Button - Default',
  builder: (context) => PrimaryButton(
    label: 'Like',
    onPressed: () {},
  ),
),
WidgetbookUseCase(
  name: 'Primary Button - Loading',
  builder: (context) => PrimaryButton(
    label: 'Like',
    onPressed: () {},
    isLoading: true,  // See loading state!
  ),
),
```

**Hot reload → see both states instantly!**

### 3. Use Component in Real Screen

```dart
// lib/screens/discovery_screen.dart
import '../widgets/common/primary_button.dart';

// Now you use the SAME button everywhere
PrimaryButton(
  label: 'Like',
  onPressed: () => handleLike(),
)
```

**Change button once → updates everywhere!**

---

## 💎 The Power of This System

### Scenario 1: Designer Says "Make buttons rounder"

**Without system:**
- Find every button in codebase (15+ places)
- Change each one individually
- Miss some, UI inconsistent
- **Time: 2 hours**

**With your system:**
```dart
// Change ONCE in lib/theme/app_theme.dart
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // was 12
    ),
  ),
),
```
- Hot reload
- All buttons updated everywhere
- **Time: 30 seconds**

### Scenario 2: "Try a different brand color"

**Change ONCE:**
```dart
// lib/theme/app_theme.dart
static const primaryColor = Color(0xFF9B59B6); // Try purple
```

- Hot reload
- See ALL screens with new color
- Don't like it? Change back
- **Experiment in real-time**

### Scenario 3: Building ProfileCard (your actual next task)

**Step 1:** Build in Widgetbook
```dart
// lib/widgets/discovery/profile_card.dart
class ProfileCard extends StatelessWidget {
  final String name;
  final int age;
  final String photoUrl;
  final int matchScore;
  
  // Build with hot reload, see instantly
}
```

**Step 2:** Preview in Widgetbook
```dart
// Try different data states
WidgetbookUseCase(
  name: 'Profile Card - High Match',
  builder: (context) => ProfileCard(
    name: 'Erik',
    age: 29,
    photoUrl: 'https://picsum.photos/400/600',
    matchScore: 92,
  ),
),
WidgetbookUseCase(
  name: 'Profile Card - Low Match',
  builder: (context) => ProfileCard(
    name: 'Anna',
    age: 25,
    photoUrl: 'https://picsum.photos/400/600',
    matchScore: 65,
  ),
),
```

**Step 3:** Use in real screen
```dart
// lib/screens/discovery_screen.dart
CardSwiper(
  cards: candidates.map((c) => ProfileCard(
    name: c.name,
    age: c.age,
    photoUrl: c.photoUrl,
    matchScore: c.matchScore,
  )).toList(),
)
```

**Result:** Built once, works everywhere, looks professional

---

## 🗂️ Git Workflow (Persistence)

### Every component is version controlled

```bash
# Create new component
git add lib/widgets/discovery/profile_card.dart
git commit -m "feat: Add ProfileCard component"

# Change existing component
git diff lib/widgets/common/primary_button.dart
# See what changed

git commit -m "refactor: Make buttons more rounded"

# Revert if you don't like changes
git revert HEAD
```

**You never lose work. Every change is tracked.**

### Branches for experiments

```bash
# Try a design idea
git checkout -b experiment/gradient-backgrounds
# Make changes

# Like it? Merge
git checkout main && git merge experiment/gradient-backgrounds

# Don't like it? Delete branch
git branch -D experiment/gradient-backgrounds
```

---

## 📊 Consistency Rules (Enforced by Code)

### Design Tokens (Single Source of Truth)

```dart
// lib/theme/spacing.dart
class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;  // THIS is the spacing
  static const lg = 24.0;
}

// Use EVERYWHERE
Padding(padding: EdgeInsets.all(Spacing.md))
SizedBox(height: Spacing.lg)

// NOT magic numbers like:
Padding(padding: EdgeInsets.all(15))  // ❌ WRONG
```

**Result:** Spacing is consistent because it's IMPOSSIBLE to be inconsistent.

### Color Tokens

```dart
// Use theme colors
Container(color: Theme.of(context).colorScheme.primary)  // ✅ RIGHT

// NOT raw values
Container(color: Color(0xFFFF7F50))  // ❌ WRONG (what if brand changes?)
```

---

## 🚀 Next Steps (Start Today)

### 1. See Your Design System (5 minutes)

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
./run-widgetbook.sh
```

Opens browser showing:
- All your brand colors with hex codes
- Typography styles
- Button examples

**Play with it!** Change colors in `app_theme.dart`, hot reload, see changes.

### 2. Build ProfileCard Component (2-3 hours)

```bash
# Create component file
touch lib/widgets/discovery/profile_card.dart

# Add to Widgetbook
# Edit lib/widgetbook.dart

# Preview as you build
./run-widgetbook.sh
```

**See it** → **Iterate** → **Perfect it** → **Use it**

### 3. Commit to Git (1 minute)

```bash
git add lib/widgets/discovery/profile_card.dart
git add lib/widgetbook.dart
git commit -m "feat: Add ProfileCard component with match score display"
```

**Now it's saved forever. Can iterate tomorrow, next week, next month.**

---

## 🎓 Learning Resources

- **Widgetbook Docs**: https://docs.widgetbook.io
- **Material Design 3**: https://m3.material.io
- **Flutter Component Patterns**: https://flutter.dev/docs/development/ui/widgets-intro

---

## ✅ Success Checklist

After 1 week with this system:

- [ ] 5+ reusable components built (Button, Card, Input, etc.)
- [ ] All components in Widgetbook catalog
- [ ] All components in Git with commit messages
- [ ] Changed brand color once and saw it update everywhere
- [ ] Reused same component in 3+ different screens
- [ ] Never manually copied component code

**If you can check all boxes, you have a professional design system!**

---

**Last Updated**: February 3, 2026  
**Status**: Foundation complete, ready for component development  
**Next**: Build ProfileCard component (T035)
