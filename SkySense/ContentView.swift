import SwiftUI

struct ContentView: View {
    @StateObject private var astronomyEngine = AstronomyEngine()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var hapticManager = HapticManager()
    
    @State private var alignmentOffsetAzimuth: Double = 0.0
    @State private var alignmentOffsetAltitude: Double = 0.0
    
    @State private var dragStartAzimuth: Double = 0.0
    @State private var dragStartAltitude: Double = 0.0
    
    @State private var selectedFilter: CelestialObjectType = .planet
    
    var body: some View {
        ZStack {
            // 1. Raw Camera Background
            CameraPreviewView(session: cameraManager.session)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            alignmentOffsetAzimuth = dragStartAzimuth - Double(value.translation.width) * 0.1
                            alignmentOffsetAltitude = dragStartAltitude + Double(value.translation.height) * 0.1
                        }
                        .onEnded { _ in
                            dragStartAzimuth = alignmentOffsetAzimuth
                            dragStartAltitude = alignmentOffsetAltitude
                        }
                )
            
            // 2. Nearest UI Layer
            if let nearest = getNearestTarget() {
                let calibratedAz = motionManager.deviceAzimuth + alignmentOffsetAzimuth
                let calibratedAlt = motionManager.deviceAltitude + alignmentOffsetAltitude
                
                let dist = AstronomyMath.angularDistance(
                    alt1: calibratedAlt, az1: calibratedAz,
                    alt2: nearest.alt, az2: nearest.az
                )
                
                if dist < 8.0 {
                    // TARGET IN FOV -> Render the "Locked" Tooltip
                    VStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text(nearest.object.name)
                                .font(.headline).bold()
                                .foregroundColor(.white)
                            Text("Locked (\(String(format: "%.1f", dist))°)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .liquidGlass()
                        Spacer()
                    }
                } else {
                    // TARGET OFF SCREEN -> Render Directional Edge Arrow
                    let angle = angleToTarget(
                        deviceAz: calibratedAz,
                        deviceAlt: calibratedAlt,
                        targetAz: nearest.az,
                        targetAlt: nearest.alt
                    )
                    
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 5)
                        .rotationEffect(.degrees(90 - angle)) // Adjust so pointing correctly
                        .offset(x: cos(angle * .pi / 180) * 150, y: -sin(angle * .pi / 180) * 150)
                }
            }
            
            // 3. Heads Up UI Overlay
            VStack {
                // Top HUD
                HStack {
                    // Category Pills ScrollView
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
                .padding(.top, 50)
                
                Spacer()
                
                // Reticle / Crosshair in Center
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                // Minimal Status Footer
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calibrated Drift")
                            .font(.caption).bold().foregroundColor(.gray)
                        Text("Az: \(alignmentOffsetAzimuth, specifier: "%.1f")° | Alt: \(alignmentOffsetAltitude, specifier: "%.1f")°")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            dragStartAzimuth = alignmentOffsetAzimuth
            dragStartAltitude = alignmentOffsetAltitude
            astronomyEngine.startTracking()
            motionManager.start()
        }
        .onDisappear {
            astronomyEngine.stopTracking()
            motionManager.stop()
            hapticManager.stopContinuous()
        }
        .onChange(of: motionManager.deviceAzimuth) { _ in updateSensoryEngine() }
        .onChange(of: motionManager.deviceAltitude) { _ in updateSensoryEngine() }
        .onChange(of: selectedFilter) { _ in updateSensoryEngine() }
    }
    
    private func getNearestTarget() -> TargetCoordinates? {
        let filtered = astronomyEngine.activeTargets.filter { $0.object.type == selectedFilter }
        guard !filtered.isEmpty else { return nil }
        
        let calAz = motionManager.deviceAzimuth + alignmentOffsetAzimuth
        let calAlt = motionManager.deviceAltitude + alignmentOffsetAltitude
        
        return filtered.min { a, b in
            let distA = AstronomyMath.angularDistance(alt1: calAlt, az1: calAz, alt2: a.alt, az2: a.az)
            let distB = AstronomyMath.angularDistance(alt1: calAlt, az1: calAz, alt2: b.alt, az2: b.az)
            return distA < distB
        }
    }
    
    private func angleToTarget(deviceAz: Double, deviceAlt: Double, targetAz: Double, targetAlt: Double) -> Double {
        var dAz = targetAz - deviceAz
        if dAz > 180 { dAz -= 360 }
        if dAz < -180 { dAz += 360 }
        
        let dAlt = targetAlt - deviceAlt
        return atan2(dAlt, dAz) * 180 / .pi
    }
    
    private func updateSensoryEngine() {
        guard let nearest = getNearestTarget() else {
            hapticManager.updateHapticFeedback(distance: 999)
            return
        }
        
        let calAz = motionManager.deviceAzimuth + alignmentOffsetAzimuth
        let calAlt = motionManager.deviceAltitude + alignmentOffsetAltitude
        
        let dist = AstronomyMath.angularDistance(alt1: calAlt, az1: calAz, alt2: nearest.alt, az2: nearest.az)
        
        // Feed the distance straight into the sensory haptics engine
        hapticManager.updateHapticFeedback(distance: dist)
    }
}

#Preview {
    ContentView()
}
