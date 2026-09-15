import SwiftUI

struct ContentView: View {
    @StateObject private var astronomyEngine = AstronomyEngine()
    @StateObject private var motionManager = MotionManager()
    
    // Phase 2: Calibration Offsets
    @State private var alignmentOffsetAzimuth: Double = 0.0
    @State private var alignmentOffsetAltitude: Double = 0.0
    
    // Status state to update the UI
    @State private var isTargetCentered: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SkySense Sensor Tracking")
                .font(.title2)
                .fontWeight(.bold)
            
            GroupBox("Device Orientation") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Azimuth: \(motionManager.deviceAzimuth + alignmentOffsetAzimuth, specifier: "%.1f")°")
                    Text("Altitude: \(motionManager.deviceAltitude + alignmentOffsetAltitude, specifier: "%.1f")°")
                }
            }
            
            GroupBox("Target (Jupiter) Pos") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Azimuth: \(astronomyEngine.lastAzimuth, specifier: "%.1f")°")
                    Text("Altitude: \(astronomyEngine.lastAltitude, specifier: "%.1f")°")
                }
            }
            
            if isTargetCentered {
                Text("TARGET CENTERED")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            } else {
                Text("Align device with target...")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            astronomyEngine.startTracking()
            motionManager.start()
        }
        .onDisappear {
            astronomyEngine.stopTracking()
            motionManager.stop()
        }
        // Continuous check for centering
        .onChange(of: motionManager.deviceAzimuth) { _ in
            checkCentering()
        }
        .onChange(of: motionManager.deviceAltitude) { _ in
            checkCentering()
        }
    }
    
    private func checkCentering() {
        let calibratedAzimuth = motionManager.deviceAzimuth + alignmentOffsetAzimuth
        let calibratedAltitude = motionManager.deviceAltitude + alignmentOffsetAltitude
        
        let targetAzimuth = astronomyEngine.lastAzimuth
        let targetAltitude = astronomyEngine.lastAltitude
        
        // Skip check if we don't have valid target data yet
        guard targetAzimuth > 0 || targetAltitude > 0 else { return }
        
        let distance = AstronomyMath.angularDistance(
            alt1: calibratedAltitude,
            az1: calibratedAzimuth,
            alt2: targetAltitude,
            az2: targetAzimuth
        )
        
        let wasCentered = isTargetCentered
        let isNowCentered = distance < 5.0 // 5 degrees threshold
        
        if isNowCentered != wasCentered {
            isTargetCentered = isNowCentered
            if isNowCentered {
                print("Target Centered! (Distance: \(String(format: "%.1f", distance))°)")
            }
        }
    }
}

#Preview {
    ContentView()
}
