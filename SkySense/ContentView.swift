import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var astronomyEngine = AstronomyEngine()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var hapticManager = HapticManager()
    
    @State private var selectedFilter: CelestialObjectType = .planet
    @State private var selectedCelestialObject: CelestialObject?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Raw Camera Background
                CameraPreviewView(session: cameraManager.session)
                    .edgesIgnoringSafeArea(.all)
                
                // 2. 3D AR Projections
                if let rm = motionManager.rotationMatrix {
                    let filteredTargets = astronomyEngine.activeTargets.filter { $0.object.type == selectedFilter }
                    
                    // Render dots for all targets in FOV
                    ForEach(filteredTargets, id: \.object.id) { target in
                        if let point = AstronomyMath.project(alt: target.alt, az: target.az, rm: rm, screenSize: geometry.size) {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 8, height: 8)
                                .shadow(color: .white, radius: 4)
                                .position(point)
                            
                            Text(target.object.name)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .position(x: point.x, y: point.y - 15)
                        }
                    }
                    
                    // Nearest Target logic
                    if let nearest = getNearestTarget(targets: filteredTargets, rm: rm) {
                        let vec = getDeviceVector(alt: nearest.alt, az: nearest.az, rm: rm)
                        let isLocked = isTargetLocked(target: nearest, rm: rm, size: geometry.size)
                        
                        if isLocked {
                            // TARGET IN FOV -> Render the "Locked" Tooltip
                            VStack {
                                Spacer()
                                Button(action: {
                                    selectedCelestialObject = nearest.object
                                }) {
                                    VStack(spacing: 4) {
                                        Text(nearest.object.name)
                                            .font(.headline).bold()
                                            .foregroundColor(.white)
                                        Text("Locked")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .liquidGlass()
                                }
                                Spacer()
                            }
                        } else {
                            // TARGET OFF CENTER -> Render Directional Edge Arrow
                            // In screen space: +X is right, +Y is DOWN (so device +Y is screen -Y)
                            let angle = atan2(-vec.dy, vec.dx)
                            
                            Image(systemName: "location.north.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(color: .white, radius: 5)
                                // Arrow points UP normally. Rotate it +90 to point RIGHT (0 radians)
                                .rotationEffect(.radians(angle + .pi / 2.0))
                                .offset(x: cos(angle) * 150, y: sin(angle) * 150)
                        }
                    }
                }
                
                // 3. Heads Up UI Overlay
                VStack {
                    // Top Empty space / status
                    HStack {
                        VStack(alignment: .leading) {
                            Text("3D AR Tracking Active")
                                .font(.caption).bold().foregroundColor(.green)
                        }
                        .padding()
                        .padding(.top, 50)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Reticle / Crosshair in Center
                    Image(systemName: "plus")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    // Bottom HUD (Category Pills and Toggle)
                    HStack(alignment: .bottom) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button(action: { selectedFilter = .planet }) {
                                    Text("Planets")
                                        .fontWeight(selectedFilter == .planet ? .bold : .medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.white)
                                        .liquidGlass()
                                }
                                Button(action: { selectedFilter = .star }) {
                                    Text("Bright Stars")
                                        .fontWeight(selectedFilter == .star ? .bold : .medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.white)
                                        .liquidGlass()
                                }
                                Button(action: { selectedFilter = .satellite }) {
                                    Text("Satellites")
                                        .fontWeight(selectedFilter == .satellite ? .bold : .medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.white)
                                        .liquidGlass()
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        // Night Vision Toggle
                        Button(action: {
                            cameraManager.isNightVisionEnabled.toggle()
                        }) {
                            Image(systemName: cameraManager.isNightVisionEnabled ? "moon.stars.fill" : "moon")
                                .font(.title3)
                                .foregroundColor(cameraManager.isNightVisionEnabled ? .yellow : .white)
                                .padding(12)
                                .liquidGlass()
                        }
                        .padding(.trailing)
                    }
                    .padding(.bottom, 30)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                astronomyEngine.startTracking()
                motionManager.start()
            }
            .onDisappear {
                astronomyEngine.stopTracking()
                motionManager.stop()
                hapticManager.pause()
            }
            .onChange(of: motionManager.deviceAzimuth) { updateSensoryEngine(geometry: geometry) }
            .onChange(of: selectedFilter) { updateSensoryEngine(geometry: geometry) }
            .sheet(item: $selectedCelestialObject) { object in
                CelestialStorySheet(object: object)
                    .presentationBackground(.ultraThinMaterial)
                    .preferredColorScheme(.dark)
                    .presentationDetents([.fraction(0.4), .large])
                    .onAppear {
                        cameraManager.pause()
                        hapticManager.pause()
                    }
                    .onDisappear {
                        cameraManager.resume()
                    }
            }
        }
    }
    
    // Calculates the 3D vector of a celestial object in the device's local coordinate system.
    private func getDeviceVector(alt: Double, az: Double, rm: CMRotationMatrix) -> (dx: Double, dy: Double, dz: Double) {
        let altRad = alt * .pi / 180.0
        let azRad = az * .pi / 180.0
        let x = cos(altRad) * sin(azRad)
        let y = cos(altRad) * cos(azRad)
        let z = sin(altRad)
        
        let localX = rm.m11 * x + rm.m21 * y + rm.m31 * z
        let localY = rm.m12 * x + rm.m22 * y + rm.m32 * z
        let localZ = -(rm.m13 * x + rm.m23 * y + rm.m33 * z)
        
        return (dx: localX, dy: localY, dz: localZ)
    }
    
    // Finds the target that is closest to the center of the camera (-Z axis).
    private func getNearestTarget(targets: [TargetCoordinates], rm: CMRotationMatrix) -> TargetCoordinates? {
        guard !targets.isEmpty else { return nil }
        
        // The most positive `dz` means the vector is most closely aligned with the camera axis.
        return targets.max { a, b in
            let vecA = getDeviceVector(alt: a.alt, az: a.az, rm: rm)
            let vecB = getDeviceVector(alt: b.alt, az: b.az, rm: rm)
            return vecA.dz < vecB.dz
        }
    }
    
    private func isTargetLocked(target: TargetCoordinates, rm: CMRotationMatrix, size: CGSize) -> Bool {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        if let point = AstronomyMath.project(alt: target.alt, az: target.az, rm: rm, screenSize: size) {
            let dist = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
            return dist < 80.0
        }
        return false
    }
    
    private func updateSensoryEngine(geometry: GeometryProxy) {
        guard let rm = motionManager.rotationMatrix else { return }
        let filteredTargets = astronomyEngine.activeTargets.filter { $0.object.type == selectedFilter }
        
        guard let nearest = getNearestTarget(targets: filteredTargets, rm: rm) else {
            hapticManager.updateHapticFeedback(distance: 999)
            return
        }
        
        // Convert the 3D angular alignment into an abstract distance for haptics.
        // `dz` is the cosine of the angle between the target and the camera axis.
        // theta = acos(dz). We multiply by 180/pi to get degrees.
        let vec = getDeviceVector(alt: nearest.alt, az: nearest.az, rm: rm)
        let clampedDz = max(-1.0, min(1.0, vec.dz))
        let angularDist = acos(clampedDz) * 180.0 / .pi
        
        hapticManager.updateHapticFeedback(distance: angularDist)
    }
}


struct CelestialStorySheet: View {
    let object: CelestialObject
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: object.type == .planet ? "circle.hexagonpath" : (object.type == .satellite ? "globe.americas" : "sparkles"))
                        .font(.largeTitle)
                        .foregroundColor(object.type == .planet ? .orange : (object.type == .satellite ? .green : .cyan))
                        .shadow(color: .white.opacity(0.3), radius: 10)
                    
                    VStack(alignment: .leading) {
                        Text(object.name)
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                        
                        Text(object.type == .planet ? "Planet" : (object.type == .satellite ? "Satellite" : "Star"))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 20)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Magnitude")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(String(format: "%.2f", object.apparentMagnitude))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Right Ascension")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(String(format: "%.1f°", object.ra))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Declination")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(String(format: "%.1f°", object.dec))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 10)
                
                Text(object.storyDescription)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white.opacity(0.95))
                    .lineSpacing(6)
                
                Spacer()
            }
            .padding(30)
        }
    }
}

#Preview {
    ContentView()
}
