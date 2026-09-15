# AI Agent Implementation Plan: SkySense

**Tech Stack:** iOS, Swift, SwiftUI, AVFoundation (Raw Camera), CoreMotion, CoreHaptics, Combine.
**Workflow Rule:** Execute this plan one phase at a time. Do not move to the next phase until the success metric of the current phase is fully met and tested.

## Phase 1: The Astronomy Engine (Data & Math)
**Goal:** Establish the foundational math to know *where* objects are before rendering any UI.
* **Task 1.1:** Create an `AstronomyMath` utility that takes GPS coordinates (`CoreLocation`) and current UTC time, and outputs Local Sidereal Time (LST).
* **Task 1.2:** Build a lightweight local database (Struct model) of the 8 Planets and the 50 brightest stars. Include `id`, `name`, `type`, `apparentMagnitude`, `ra`, `dec`, and `storyDescription`.
* **Task 1.3:** Implement an algorithm to convert Right Ascension/Declination (RA/Dec) from the database into local Altitude/Azimuth (Alt/Az) based on location and LST.
* **Success Metric:** A background service that accurately prints to the Xcode console: *"Jupiter is currently at Azimuth 180°, Altitude 45°."*

## Phase 2: Sensor Fusion & Math Tracking
**Goal:** Track phone orientation strictly via sensors (no ARKit/vision tracking).
* **Task 2.1:** Implement a `MotionManager` using `CoreMotion` (`CMMotionManager.deviceMotion`) to track the device's yaw, pitch, and roll in real-time.
* **Task 2.2:** Map the device's physical orientation to celestial Alt/Az coordinates.
* **Task 2.3:** Add an `alignmentOffset` `@State` variable (Azimuth/Altitude offset). This will allow users to manually calibrate the tracking later to fix compass drift.
* **Success Metric:** The app calculates the angular distance between the center of the phone's screen and the known coordinates of a planet, printing "Target Centered" when pointed accurately.

## Phase 3: AVFoundation Camera & Night Vision
**Goal:** Build the raw camera feed with manual exposure controls.
* **Task 3.1:** Create a `CameraManager` using `AVFoundation`. Output the feed to a `UIViewRepresentable` wrapping `AVCaptureVideoPreviewLayer`.
* **Task 3.2:** Implement the **Night Vision Toggle**. Create a function that modifies the `AVCaptureDevice`.
* *Normal Mode:* 30 FPS, continuous auto-exposure.
* *Night Vision Mode:* Lock `setExposureModeCustom` to the device's maximum ISO. Drop `activeVideoMinFrameDuration` and `activeVideoMaxFrameDuration` to 10 FPS (1/10th second) to maximize light gathering.
* **Success Metric:** The user can toggle a button and immediately see the camera feed become much brighter (albeit with lower framerate/motion blur).

## Phase 4: The Viewfinder UI & Calibration
**Goal:** Build the SwiftUI overlay, guide the user, and allow compass correction.
* **Task 4.1:** Build the UI overlay with a central targeting reticle and bottom Category Pills (`@State` driven).
* **Task 4.2:** Implement **Directional Edge Arrows**. If the active target is off-screen, calculate the shortest path and display a small glowing arrow on the edge of the screen pointing toward it.
* **Task 4.3:** Render the clickable SwiftUI tooltip over the target when it enters the FOV.
* **Task 4.4:** Implement a `DragGesture` on the full-screen overlay. Panning a finger across the screen updates the `alignmentOffset` (from Phase 2), allowing the user to manually shift the tooltips to align with the bright stars in the camera feed.
* **Success Metric:** Tooltips float accurately based on math, edge arrows guide the user to the target, and dragging the screen calibrates the alignment.

## Phase 5: The Sensory Engine (Haptics)
**Goal:** Implement the "feel your way to the stars" mechanic.
* **Task 5.1:** Integrate `CoreHaptics` and create a `HapticManager`.
* **Task 5.2:** Map the angular distance calculated in Phase 2 to haptic intensity.
* *Distance > 15°:* Silence (rely on visual edge arrows).
* *Distance 15° to 5°:* Slow, soft pulsing.
* *Distance < 5°:* Rapid, sharper pulsing.
* *Distance < 1° (Locked):* A distinct success haptic "thump".
* **Success Metric:** The user can locate a target purely by following the vibration changes as they sweep the sky.

## Phase 6: Storytelling & Performance
**Goal:** Deliver the educational payload and optimize battery.
* **Task 6.1:** Implement a SwiftUI `.sheet(item: $selectedObject)` that triggers when a tooltip is tapped. Use `.preferredColorScheme(.dark)` to force a dark UI.
* **Task 6.2:** Display the object's name, icon, and the `storyDescription`.
* **Task 6.3:** Throttle the `AstronomyMath` Alt/Az calculations to run only once every 5 seconds (stars move slowly). Let `CoreMotion` handle the 60fps UI interpolation.
* **Task 6.4:** Pause the `AVCaptureSession` and stop haptics when the bottom sheet is fully expanded to save battery.
* **Success Metric:** Tapping a locked object brings up a dark-themed informational sheet, and CPU usage drops significantly while reading.
