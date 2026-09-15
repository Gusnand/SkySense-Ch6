# AI Agent Implementation Plan: SkySense

**Tech Stack:** iOS, Swift, SwiftUI, AVFoundation (Raw Camera), CoreMotion, CoreHaptics, Combine.
### STRICT WORKFLOW RULES FOR AI AGENT
You are required to follow these rules unconditionally during execution:
1. **Strict Phasing:** Execute this plan strictly one phase at a time. Do not move to the next phase or start writing code for future phases until I confirm the success metric of the current phase is fully met and tested.
2. **Verification Build:** Before presenting the final code for a phase, you must self-verify the code. Check for syntax errors, missing framework imports (e.g., `SwiftUI`, `AVFoundation`, `CoreMotion`, `CoreHaptics`), and correct SwiftUI state management. Ensure the code is production-ready and compilable without warnings.
3. **Mandatory Commit Message:** At the successful conclusion of *every* phase, you MUST generate a Markdown-formatted Git commit message for me to copy. 
   * Use Conventional Commits format (e.g., `feat:`, `fix:`, `chore:`).
   * Include a clear subject line.
   * Include a bulleted body explaining the specific technical additions made during that phase. 
*Format your commit message exactly like this at the end of each phase:*
```text
**Commit Message:**
`feat: [Phase Name] - [Short description]`
* [Detail 1]
* [Detail 2]
```

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

## Phase 4: The Viewfinder UI & Liquid Glass Styling
**Goal:** Build the SwiftUI overlay, guide the user, and implement the premium translucent UI aesthetic.
* **Task 4.1:** Build the UI overlay. Implement the Category Pills using a strict "Liquid Glass" SwiftUI modifier stack. 
  * *Agent Instruction:* Use `.background(.ultraThinMaterial)` combined with a `.clipShape(Capsule())`. Apply an `.overlay` with a `Capsule().stroke(lineWidth: 1)` using a `LinearGradient` (e.g., white to clear) to create a glowing glass edge. Add a subtle `.shadow(color: .white.opacity(0.2), radius: 10)` for the outer glow.
* **Task 4.2:** Implement **Directional Edge Arrows**. If the active target is off-screen, display a small glowing arrow on the edge of the screen pointing toward it, utilizing the same translucent styling.
* **Task 4.3:** Render the clickable SwiftUI tooltip over the target when it enters the FOV. This tooltip should also be a small `ultraThinMaterial` pill with a glowing border.
* **Task 4.4:** Implement a `DragGesture` on the full-screen overlay. Panning a finger updates the `alignmentOffset` (from Phase 2), manually shifting the tooltips to fix compass drift.
* **Success Metric:** The overlay elements (pills and tooltips) look like glowing, frosted glass that beautifully refracts the dark camera feed behind them.

## Phase 5: The Sensory Engine (Haptics)
**Goal:** Implement the "feel your way to the stars" mechanic.
* **Task 5.1:** Integrate `CoreHaptics` and create a `HapticManager`.
* **Task 5.2:** Map the angular distance calculated in Phase 2 to haptic intensity.
* *Distance > 15°:* Silence (rely on visual edge arrows).
* *Distance 15° to 5°:* Slow, soft pulsing.
* *Distance < 5°:* Rapid, sharper pulsing.
* *Distance < 1° (Locked):* A distinct success haptic "thump".
* **Success Metric:** The user can locate a target purely by following the vibration changes as they sweep the sky.

## Phase 6: Storytelling & Translucent Bottom Sheet
**Goal:** Deliver the educational payload using a highly polished, vibrant modal presentation.
* **Task 6.1:** Implement a SwiftUI `.sheet(item: $selectedObject)` or a custom draggable modal that triggers when a tooltip is tapped.
* **Task 6.2:** Style the bottom sheet background to match the iOS "Liquid Glass" aesthetic. 
  * *Agent Instruction:* Do not use a solid background color. Use `.presentationBackground(.regularMaterial)` or `.ultraThinMaterial` and ensure `.preferredColorScheme(.dark)` is active so the blur adapts to dark mode, allowing the camera feed to subtly bleed through the sheet.
* **Task 6.3:** Display the object's name, icon, and the `storyDescription` using high-contrast, hierarchical typography (e.g., `.font(.title2.weight(.semibold))`).
* **Task 6.4:** Throttle the `AstronomyMath` Alt/Az calculations to run only once every 5 seconds. Let `CoreMotion` handle the 60fps UI interpolation.
* **Task 6.5:** Pause the `AVCaptureSession` and stop haptics when the bottom sheet is fully expanded to save battery.
* **Success Metric:** Tapping a locked object brings up a stunning, frosted-glass sheet, and CPU usage drops significantly while reading.
