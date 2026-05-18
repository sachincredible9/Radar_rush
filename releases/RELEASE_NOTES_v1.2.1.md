# 🏎️ Radar Rush — Release Notes (v1.2.1+24)

## 📌 Release Overview
**Radar Rush v1.2.1 (Build 24)** is a targeted visual polish and layout refinement release designed to elevate the gameplay experience across compact Android devices. This release optimizes the HUD overlay coordinates to expand active airspace visibility, restructures the interactive flight manual for crystal-clear readability, and guarantees perfect alignment of login fields on mobile ports.

---

## ✨ What's New

### 📱 Dynamic & Maximized Active Airspace (HUD Polish)
* **Reactive HUD Coordinates**: Re-architected the HUD initialization math in [hud.dart](file:///Users/sachin/Desktop/Pers/ok/git-prj/Radar_rush/lib/ui/hud.dart) to automatically position the command panel right above the system navigation bar (with safe area considerations).
* **Game Canvas Expansion**: Shrinking margins freed up a massive vertical portion of the screen. Active runways, gates, and aircraft trajectories are now fully unobstructed.
* **Compact Device Support**: Added tailored layouts for narrow viewport profiles to ensure that gameplay controls remain highly responsive and never overlap.

### 📖 Immersive Flight Manual (Opaque Scaffold Transition)
* **Isolated Focus**: Refactored the `Instructions` overlay in [instructions.dart](file:///Users/sachin/Desktop/Pers/ok/git-prj/Radar_rush/lib/ui/instructions.dart) into a standalone, beautiful opaque manual.
* **Readability Polish**: Eliminated dark glassmorphic overlaps with the active game canvas, rendering text and airport telemetry status indicators with high typographic contrast.
* **Premium Asset Dictionary**: Includes interactive playback triggers to preview system sounds, ATC warnings, and engine roars directly inside the manual.

### 🔑 Perfect Login Form Alignment
* Resolved field alignment and spacing quirks inside [login_screen.dart](file:///Users/sachin/Desktop/Pers/ok/git-prj/Radar_rush/lib/ui/login_screen.dart) for small-viewport devices.
* Form fields and social auth targets are beautifully centered with flawless reactive vertical proportions.

---

## 🛠️ Performance & Stability Fixes
* **Graceful Transitions**: Smooth animation curves applied to panel entries and modal dismissals.
* **Memory & Thread Optimization**: Cleaned up dangling sound playback streams during UI context transitions.

---

## 📦 Release Artifacts Information

| Artifact Type | Filename | Path | Purpose |
| :--- | :--- | :--- | :--- |
| **Android App Bundle (.aab)** | `Radar_Rush_1.2.1-24_2026-05-18_prod.aab` | `releases/android/1.2.1-24/prod/` | Google Play Store Upload (Production/Closed Testing) |
| **Android Release APK (.apk)** | `Radar_Rush_1.2.1-24_2026-05-18_prod.apk` | `releases/android/1.2.1-24/prod/` | Local Device Testing / Side-loading |

---

## 🔧 Deployment Checklist (Android Closed Testing)
To upload this build to your Google Play Console:
1. Log in to the [Google Play Console](https://play.google.com/console/).
2. Select your application **Radar Rush**.
3. Navigate to **Testing** -> **Closed Testing** (or **Internal Testing**).
4. Click **Create new release**.
5. Upload the production app bundle `Radar_Rush_1.2.1-24_2026-05-18_prod.aab`.
6. Copy and paste the **What's New** release notes text below and submit the release!

---

### 📝 Google Play Console Changelog Text (What's New)
```
- Re-architected interactive HUD command panels to dynamically position themselves, unlocking a much larger visible airspace for precision ATC tracking.
- Redesigned Flight Manual instructions to utilize beautiful opaque pages, maximizing text readability and detail clarity.
- Streamlined spacing on the futuristic authorization terminal for perfect alignment on compact phone viewports.
- Performance tuning for smoother scrolling and asset transitions.
```
