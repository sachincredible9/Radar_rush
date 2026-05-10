# Airplane Landing: Ultimate ATC Simulator

A premium, high-stakes Air Traffic Control simulation built with Flutter and Flame. Manage busy international airports, coordinate landings, and ensure safe departures across the globe.

## 🚀 Key Features

### 1. Advanced Command Center
- **Resizable & Movable HUD**: Drag the control panel anywhere on the screen and resize it to fit your workflow.
- **Dynamic Content Scaling**: Interface automatically adapts for iPad Pro and iPhone displays.
- **Aviation-Grade Telemetry**: Real-time tracking of Flight Number, Status, Speed (SPD), and Heading (HDG).

### 2. Professional Flight Controls
- **Precision Vectoring**: Manually change aircraft heading with 30-degree turn controls.
- **Throttle Management**: Step-based speed control (30 units per tap) with a safety minimum of 10 and a max of 600.
- **Hover/Slow Flight**: Drastically reduce speed to manage heavy traffic congestion.
- **Boundary Fail-Safe**: Smart boundary detection prevents aircraft from being lost off-screen; they gently auto-turn back toward the airport center.

### 3. Realistic Airport Operations
- **Authentic IATA Codes**: Fly into Heathrow (LHR), JFK, Dubai (DXB), Changi (SIN), and more.
- **Manual Parking Phase**: New interactive gameplay—planes reach the apron and require the user to **DRAG** them to the correct highlighted RED gate.
- **Unique Gate Management**: Intelligent slot allocation ensures every taxiing plane has a unique, dedicated parking target.
- **Smart Ground Handling**: Mandatory 4-second servicing interval at terminal gates before takeoff clearance.
- **Multi-Phase ATC**: Manage En-Route, Holding, Landing, Taxiing, Ready-to-Park, and Departure phases.

### 4. Advanced Authentication & Security
- **Triple-Auth Suite**: Professional-grade login options including **Google Sign-In**, **Apple Sign-In**, and traditional **Email/Password**.
- **Platform-Native Experience**: Automatically prioritizes Apple on iOS and Google on Android for a seamless user journey.
- **Environment-Aware Infrastructure**: Intelligent build system that automatically swaps between **Development** and **Production** Firebase configurations.
- **Secure Persistence**: Integrated session management—log in once, stay authenticated across app launches.

### 5. Immersion & Feedback
- **ATC Voice Announcements**: Real-time synthesized voice feedback for all major events (Touchdown, Parked, Milestones).
- **Radar Entry Pings**: Instant audio-visual alerts (Radar Ping + Flight Number) when new aircraft enter the sector.
- **Immersive Takeoff Audio**: Realistic engine roar that dynamically fades and drifts away as the aircraft departs the radar range.
- **Precision Drag-Drop**: High-precision collision detection (30px) for parking at gates with automatic snap-back for invalid positions.
- **Ambient Atmosphere**: Immersive airport crowd ambiance on all menu and selection screens.
- **Milestone Celebrations**: "Hurrah!" voice announcements and festive balloon particle effects at major score milestones (1k, 3k, 5k, etc.).
- **Premium Aesthetics**: Dark-themed industrial design with vibrant neon accents and high-contrast typography.

## 📡 Aviation Audio Dictionary

The following audio cues are essential for professional ATC operations:

- **RADAR PING**: Indicates a new aircraft contact has appeared in your sector. Immediately followed by the flight number.
- **AIRPORT SELECTION**: A high-fidelity confirmation chime when an airport is selected from the menu.
- **TAKEOFF ROAR**: Signals that an aircraft has successfully initiated its departure run. Volume fades as the plane departs.
- **AIRPORT CROWD**: Ambient background chatter that sets the scene for terminal operations in the menus.
- **CRASH IMPACT**: A critical emergency sound indicating a mid-air collision. All voice announcements are silenced to prioritize this alert.

### 🎛️ Audio Control Matrix (Interactive Manual)

The **Flight Manual & Info** section includes a functional training deck where you can audition and control every operational sound:

| Sound Item | Action | UI Behavior | Operational Meaning |
| :--- | :--- | :--- | :--- |
| **Radar Ping** | Play/Toggle | Auto-resets icon | New Contact Identification |
| **Takeoff Roar** | Play/Stop | Manual toggle | Departure Power Initiation |
| **Airport Crowd** | Play/Stop | Manual toggle | Terminal Ambiance / Menus |
| **Crash Impact** | Play/Toggle | Auto-resets icon | Emergency Collision Alert |
| **Haptic Feedback** | Toggle (HUD/Manual) | Switch / Toggle Icon | Physical Collision Feedback |

## 🕹️ System Controls & Settings

- **Pause/Resume**: Instantly halt the simulation to manage strategy.
- **Master Mute**: Toggle all game audio (SFX, BGM, and Voice).
- **Haptic Control**: Enable or disable device vibration for collisions. Available in the top HUD and the Flight Manual.
- **Flight Manual**: Accessible via the 'i' icon in-game for real-time reference.

## 🛠️ Recent Improvements & Version Updates

### Mobile Optimization (iPhone 17 / iOS 17+)
- **Adaptive HUD Engine**: Implemented a responsive layout that intelligently scales telemetry data, aircraft ID, and scores to prevent overflows on any mobile screen width.
- **Pill-Layout Integration**: Vertically stacked "pill" HUD layout optimized to clear the Dynamic Island and notch areas.
- **Resizing Fixes**: Resolved overflow errors during control panel resizing by adding `FittedBox` scaling and increasing minimum height constraints.
- **Manual Alignment**: Redesigned the "Flight Manual" overlay with `SafeArea` and optimized padding for perfect alignment on modern iPhone screens.

### Gameplay Logic & Realism
- **Runway Rotation**: Implemented a round-robin runway utilization system. ATC now cycles through all available runways for landings and takeoffs, significantly improving traffic flow.
- **Flight Phase Integrity**: Enforced strict operational rules—planes must now fully land (`Touchdown`) before `TAXI` or `TAKEOFF` commands become available.
- **Instant Engagement**: Reduced the initial aircraft spawn delay to 200ms, getting players into the action immediately upon game start.

### Bug Fixes
- Fixed "Right Overflow" errors in the HUD for smaller device widths.
- Resolved title and text overlaps in the "Instructions" and "Game Over" screens using responsive `FittedBox` wrappers.
- Corrected aircraft command logic to prevent mid-air takeoffs and illegal ground movements.

## 🕹️ Controls

- **Select Plane**: Tap any aircraft in the airspace to bring up its command panel.
- **LAND**: Clears plane for approach (now uses rotated runway logic).
- **TAXI**: Directs landed planes to the apron zone (available only after touchdown).
- **DRAG (NEW)**: Manually drag aircraft from the apron to the RED highlighted gate to dock.
- **TAKEOFF**: Clears parked OR landed planes for departure.
- **HOLD**: Forces plane into a circular holding pattern.
- **TURN L/R**: Adjusts aircraft heading in 30° increments.
- **+/-**: Incremental speed adjustments.
- **STOP**: Safely halts aircraft on the taxiway or at the gate.

## 🏆 Scoring System

- **Landing Success**: 500 Points
- **Gate Parking**: 500 Points
- **Successful Takeoff**: 1500 Points
- **Collision Penalty**: -300 Points

---
*Built for the ultimate ATC enthusiast. Managed and polished with precision.*
