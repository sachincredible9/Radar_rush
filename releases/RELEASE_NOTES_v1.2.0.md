# 🏎️ Radar Rush — Release Notes (v1.2.0+23)

## 📌 Release Overview
**Radar Rush v1.2.0 (Build 23)** is a major feature and stability release designed to streamline developer execution, eliminate startup constraints, and polish the authentication gateway. This release resolves key native initialization bugs, introduces a beautiful **Play as Guest** offline bypass option, and delivers optimized, signed production release artifacts for both Android Phone and Android Tablet form factors.

---

## ✨ What's New

### 🔑 Premium Interactive Gateway & Guest Play
* **Default Login Screen Route**: The application now routes users directly to the fully styled, high-impact `LoginScreen` on boot rather than silently skipping authentication when Firebase is not configured or in offline mode.
* **"PLAY AS GUEST" Bypass**: Integrated a premium, futuristic outlined button matching the radar HUD style:
  * Allows developers and players to launch directly into the local hanger and level maps without internet or email credentials.
  * Provides complete compliance for **Google Play & App Store Reviewers**, ensuring seamless sandbox evaluation.
* **Resilient Authentication State**: Added a parent `AuthStateManager` state wrapper to manage live Firebase authentication streams concurrently with local guest sessions.

---

## 🛠️ Performance & Stability Fixes

### 🚀 Zero-Freeze Native Splash Sequence
* Swapped initialization ordering so that native splash elements (`FlutterNativeSplash.preserve`) manage the viewport immediately.
* Preserves the splash screen cleanly during resource load and terminates it gracefully right before calling `runApp()`.

### 🛡️ Crash-Proof Firebase Core Integration
* **Lazy Evaluation**: Modified the `AuthService` configuration class to lazily invoke `FirebaseAuth.instance` inside robust `try-catch` structures. This prevents cascading platform crashes when Google/Firebase Services configurations (`google-services.json`) are absent in local or emulator development environments.
* **Sequence Ordering**: Optimized the async setup chain in `main.dart` to instantiate Firebase Core prior to service injection locators.

### 🧪 100% Headless Unit Test Compliance
* Re-architected `widget_test.dart` to mock the service layer locator and isolate direct database/auth platform references, achieving 100% test completion.

---

## 📦 Release Artifacts Information

| Artifact Type | Filename | Path | Size | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Android App Bundle (.aab)** | `Radar_Rush_1.2.0-23_2026-05-18_prod.aab` | `releases/android/1.2.0-23/prod/` | **70.9 MB** | Google Play Store Upload (Production/Closed Testing) |
| **Android Release APK (.apk)** | `Radar_Rush_1.2.0-23_2026-05-18_prod.apk` | `releases/android/1.2.0-23/prod/` | **80.3 MB** | Local Device Testing / Side-loading |
| **Android Test Bundle (.aab)** | `Radar_Rush_1.2.0-23_2026-05-18_test.aab` | `releases/android/1.2.0-23/test/` | **70.9 MB** | Local Internal Testing Tracks |
| **Android Test APK (.apk)** | `Radar_Rush_1.2.0-23_2026-05-18_test.apk` | `releases/android/1.2.0-23/test/` | **80.3 MB** | Sandboxed Device QA |

---

## 🔧 Deployment Checklist (Android Closed Testing)
To upload this build to your Google Play Console:
1. Log in to the [Google Play Console](https://play.google.com/console/).
2. Select your application **Radar Rush**.
3. Navigate to **Testing** -> **Closed Testing** (or **Internal Testing**).
4. Click **Create new release**.
5. Upload the production app bundle `Radar_Rush_1.2.0-23_2026-05-18_prod.aab`.
6. Copy and paste the **What's New** release notes text below and submit the release!

---

### 📝 Google Play Console Changelog Text (What's New)
```
- Introduced "Play as Guest" mode allowing instant, credential-free access to flight simulation and training hanger maps.
- Redesigned and streamlined our futuristic login gateway with beautiful visual styling and animations.
- Resolved key startup and launching issues on the latest Android emulators and tablet devices.
- Improved audio and resource caching for optimized battery consumption and frame rates.
```
