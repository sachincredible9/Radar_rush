# Technical Requirements

## Development Environment
- **Framework**: [Flutter](https://flutter.dev) (v3.27.0 or higher recommended)
- **Game Engine**: [Flame Engine](https://flame-engine.org) (v1.17.0+)
- **Language**: [Dart](https://dart.dev)
- **IDEs**: VS Code or Android Studio with Flutter/Dart plugins

## Platform Support
- **iOS**: 
  - Minimum Deployment Target: iOS 13.0+
  - Recommended Devices: iPad (all models), iPhone 12 or newer
- **Android**:
  - Minimum SDK: 21 (Android 5.0 Lollipop)
  - Target SDK: 34 (Android 14)
- **Web**: Supported (CanvasKit renderer recommended)

## Key Dependencies
| Package | Purpose |
|---------|---------|
| `flame` | Core game loop and component management |
| `flame_audio` | Background music and spatial sound effects |
| `google_fonts` | Modern typography (Orbitron, Inter) |
| `flutter_animate` | Smooth UI transitions and effects |
| `flutter_native_splash` | Cinematic cinematic runway launch screen |

## Asset Requirements
- **Sprites**: PNG format with transparency.
- **Audio**: MP3/WAV for SFX, OGG/MP3 for BGM.
- **Hitboxes**: Circular hitboxes for optimized collision detection.

## Core Game Mechanics
- **Scoring**: 
  - Landing: +500 pts
  - Parking at Gate: +500 pts
  - Successful Takeoff: +1500 pts
- **Airplane States**:
  - `READY TO TAKEOFF`: Automatically set when the aircraft completes taxiing and stops at the terminal gate.
