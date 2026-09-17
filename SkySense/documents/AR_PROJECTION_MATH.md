# SkySense AR Projection Math & Coordinate Systems

## Overview
This document serves as a comprehensive reference for the Augmented Reality (AR) projection math used in the SkySense application. It details the journey from spherical coordinates (Altitude/Azimuth) to flat 2D screen pixels, the pitfalls of hardware matrix manipulation, and the nuances of handling physical device orientation versus UI orientation. 

Keep this file as a reference for future AI assistance or refactoring.

## The Core Problem: Why "Swimming" Happens
In AR apps like SkySense, celestial objects (stars, planets) have absolute coordinates in the real world (Altitude and Azimuth). The phone has a physical orientation (pitch, yaw, roll) measured by hardware gyroscopes. 

If the UI elements "swim" or "orbit" when panning or rolling the device, the translation between the world coordinates and the device screen coordinates is flawed. This is typically caused by:
1. Linear mapping of angles instead of true 3D projection.
2. Incorrect matrix multiplications (e.g., applying an inverse rotation due to matrix transposes).
3. Failing to compensate for UI interface orientation (Landscape vs. Portrait).

---

## 1. The Spherical to Cartesian Conversion
The first step is converting the celestial object's spherical angles (Altitude, Azimuth) into a 3D Cartesian unit vector. SkySense uses the **East-North-Up (ENU)** world coordinate system, where X is North, Y is West, and Z is Up.

```swift
let altRad = alt * .pi / 180.0
let azRad = az * .pi / 180.0

// North-West-Up mapping
let worldX = cos(altRad) * cos(azRad)   // North
let worldY = -cos(altRad) * sin(azRad)  // West
let worldZ = sin(altRad)                // Up

let worldVector = SIMD3<Double>(worldX, worldY, worldZ)
```

## 2. The Attitude Matrix & Transpose Bug
Apple's `CMMotionManager` provides a `CMRotationMatrix` that describes the device's orientation relative to a reference frame (e.g., `CMAttitudeReferenceFrame.xTrueNorthZVertical`).

### The Matrix Multiplication Trap
To convert a world vector to a device-local vector, you must multiply the attitude rotation matrix (`R`) by the world vector (`v`): `v_device = R * v_world`.

Apple's `CMRotationMatrix` exposes 9 scalars (`m11`, `m12`... `m33`).
**A common pitfall is manually writing the multiplication incorrectly:**

```swift
// WRONG: This builds the output from columns (m11, m21, m31).
// This effectively calculates Rᵀ * v, which applies the INVERSE rotation.
// Symptom: The AR object orbits in the opposite direction when the device rolls.
let wrongX = m11 * x + m21 * y + m31 * z 
```

**The Solution:** Use Swift's `simd` framework. It eliminates manual indexing errors entirely.
```swift
extension CMRotationMatrix {
    var simd3x3: simd_double3x3 {
        // simd_double3x3(columns:) takes COLUMN vectors.
        simd_double3x3(
            SIMD3(m11, m21, m31),
            SIMD3(m12, m22, m32),
            SIMD3(m13, m23, m33)
        )
    }
}

// CORRECT: simd handles the row-major multiplication safely.
let deviceVector = rm.simd3x3 * worldVector
```

## 3. Rear Camera Optical Axis (-Z)
CoreMotion defines the device's Z-axis as pointing **out of the screen** (towards the user's face). However, AR applications track the physical world using the **rear camera**, which points exactly in the opposite direction (down the -Z axis).

To fix this, the Z component must be inverted before projecting to the screen:
```swift
let localX = deviceVector.x
let localY = deviceVector.y
let localZ = -deviceVector.z // Flip Z to face out the back of the phone
```

## 4. UI Interface Orientation Compensation
Hardware gyroscopes are bolted to the chassis. They always read data relative to the device's physical **Portrait** frame. 
When a user turns the phone sideways, the SwiftUI `UIWindowScene` rotates to Landscape, but the hardware sensors do not care. If you don't compensate, the AR overlay will be rotated 90 degrees out of sync with the camera feed.

**The Fix:** Dynamically check the interface orientation and swap/invert the X and Y axes accordingly before the 2D projection.

```swift
let orientation = UIApplication.shared.connectedScenes
    .compactMap { $0 as? UIWindowScene }
    .first?.interfaceOrientation ?? .portrait

var adjX = localX
var adjY = localY

switch orientation {
case .landscapeLeft:
    adjX = -localY
    adjY = localX
case .landscapeRight:
    adjX = localY
    adjY = -localX
case .portraitUpsideDown:
    adjX = -localX
    adjY = -localY
default:
    break
}
```

## 5. Trigonometric 2D Screen Projection
Once you have the correctly rotated and oriented local vector, it must be projected onto the flat 2D screen. 

**Avoid separate Horizontal/Vertical FOVs.** Using separate Fields of View (FOV) will cause the aspect ratio to stretch and warp when the device is rolled diagonally. 
Instead, calculate a single, unified `focalLength` based on the longest dimension of the screen and a standard FOV (e.g., 60°).

```swift
let fov = 60.0 * .pi / 180.0
let focalLength = max(screenSize.width, screenSize.height) / (2.0 * tan(fov / 2.0))

// Project X and Y over the depth (Z)
let screenX = (screenSize.width / 2.0) + (adjX / localZ) * focalLength
let screenY = (screenSize.height / 2.0) - (adjY / localZ) * focalLength
```

## Summary Checklist for Future Development
- [ ] Are spherical coordinates mapped to the Cartesian vector correctly?
- [ ] Is matrix multiplication using `simd` instead of manual scalar indexing?
- [ ] Is the Z-axis inverted to account for the rear-facing camera?
- [ ] Are `localX` and `localY` passing through a `UIInterfaceOrientation` switch statement?
- [ ] Is the 2D projection using a unified focal length to prevent diagonal skew?
