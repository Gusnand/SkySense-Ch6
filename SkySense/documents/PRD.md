# Product Requirements Document (PRD)
**Product Name:** SkySense (Placeholder)
**Concept:** A one-page, sensory-first astronomy app that uses a live camera feed (AVFoundation), sensor math (CoreMotion), haptics, and audio to guide users to visible celestial objects. It relies entirely on mathematical tracking, avoiding heavy computer vision, to keep the device cool and responsive while protecting dark adaptation.

## 1. Target Audience
* **Urban stargazers:** Users living in Bortle 6-9 skies dealing with high light pollution.
* **Beginners:** People overwhelmed by traditional, data-heavy astronomy "encyclopedia" apps.
* **Active explorers:** Users who want a physical, sensory connection to the sky rather than passive reading.

## 2. Core User Journey
1. **Open & Point:** User opens the app directly to a full-screen camera view. No onboarding carousels, no complex menus.
2. **Filter:** User taps a pill button at the edge of the screen (e.g., *Planets*, *Bright Stars*, *ISS/Satellites*).
3. **Follow the Guide:** To prevent "Gorilla Arm" fatigue, an edge-of-screen arrow gently guides the user toward the nearest active object.
4. **Scan & Feel:** As the target enters the center Field of View (FOV), spatial haptic feedback and a subtle audio cue intensify.
5. **Lock & Reveal:** When centered, a glowing tooltip appears. Tapping it pulls up a bottom sheet containing a "cultural story" or fascinating fact.
6. **Night Vision (Optional):** If the user wants to see the stars on their screen, they tap the "Night Vision" toggle, which drastically brightens the camera feed at the expense of frame rate.

## 3. Feature Specifications

### 3.1 The Viewfinder (Camera UI)
* **Full-Screen Camera:** Acts as the base visual layer, built using AVFoundation for raw hardware control.
* **High-Contrast HUD:** A simple reticle in the center of the screen to indicate the targeting area. UI must be crisp and glowing to contrast against the dark/grainy night camera feed.
* **Category Pills:** A horizontally scrolling list of toggles (e.g., `Planets`, `Bright Stars`, `ISS/Satellites`). 
* **Night Vision Toggle:** A button that drops the camera frame rate (e.g., to 5-10 fps) and maxes out ISO to gather light, revealing stars on-screen.
* **Calibration Drag (Compass Drift Fix):** The user can use one finger to pan the UI overlay slightly left/right/up/down to perfectly align the digital tooltips with the real stars seen in the camera feed, correcting inherent phone compass inaccuracies.

### 3.2 Sensory Engine (Haptics, Audio, & Visuals)
* **Directional Arrows:** A subtle arrow appears on the edge of the screen pointing the shortest path to the filtered object to minimize aimless sweeping.
* **Proximity Haptics:** As a target nears the center reticle, a pulsing vibration begins, growing faster/stronger as alignment improves.
* **Audio Sonification:** A low ambient tone shifts in pitch as alignment improves, culminating in a "lock" chime.

### 3.3 The Bottom Sheet (Story-First Data)
* **Trigger:** Activated by tapping the locked tooltip in the camera view.
* **Content:** Driven by human curiosity. 
  * *Example (Jupiter):* "The King of Storms. You are looking at a gas giant so large that 1,300 Earths could fit inside it."
  * *Exclude:* Right Ascension, Declination, and raw coordinate data.
* **Dismissal:** Swiping down returns the user to the active camera view.

### 3.4 Backend & Computational Constraints
* **NO Computer Vision:** The camera is strictly a visual passthrough. It does not analyze image pixels.
* **Coordinate Math:** Uses device location (GPS), Julian Date, and Local Sidereal Time to calculate Altitude/Azimuth (Alt/Az) coordinates.
* **Sensor Fusion:** Uses `CoreMotion` (DeviceMotion) to track phone orientation, projecting the calculated Alt/Az coordinates onto the screen mathematically.
