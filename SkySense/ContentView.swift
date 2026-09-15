import SwiftUI

struct ContentView: View {
    @StateObject private var astronomyEngine = AstronomyEngine()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()
    
    @State private var alignmentOffsetAzimuth: Double = 0.0
    @State private var alignmentOffsetAltitude: Double = 0.0
    @State private var isTargetCentered: Bool = false
    
    var body: some View {
        ZStack {
            // Background Layer: Raw Camera Feed
            CameraPreviewView(session: cameraManager.session)
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                // Night Vision Toggle
                HStack {
                    Spacer()
                    Button(action: {
                        cameraManager.isNightVisionEnabled.toggle()
                    }) {
                        Image(systemName: cameraManager.isNightVisionEnabled ? "moon.stars.fill" : "moon")
                            .font(.title2)
                            .foregroundColor(cameraManager.isNightVisionEnabled ? .yellow : .white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                Spacer()
                
                // Sensor / Target Tracking Heads Up Display (HUD)
                VStack(spacing: 12) {
                    Text(isTargetCentered ? "TARGET CENTERED" : "Searching...")
                        .font(.headline)
                        .foregroundColor(isTargetCentered ? .green : .white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("DEVICE")
                                .font(.caption).bold().foregroundColor(.gray)
                            Text("Az: \(motionManager.deviceAzimuth + alignmentOffsetAzimuth, specifier: "%.1f")°")
                            Text("Alt: \(motionManager.deviceAltitude + alignmentOffsetAltitude, specifier: "%.1f")°")
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("TARGET")
                                .font(.caption).bold().foregroundColor(.gray)
                            Text("Az: \(astronomyEngine.lastAzimuth, specifier: "%.1f")°")
                            Text("Alt: \(astronomyEngine.lastAltitude, specifier: "%.1f")°")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .onAppear {
            astronomyEngine.startTracking()
            motionManager.start()
        }
        .onDisappear {
            astronomyEngine.stopTracking()
            motionManager.stop()
        }
        .onChange(of: motionManager.deviceAzimuth) { _ in checkCentering() }
        .onChange(of: motionManager.deviceAltitude) { _ in checkCentering() }
    }
    
    private func checkCentering() {
        let calibratedAzimuth = motionManager.deviceAzimuth + alignmentOffsetAzimuth
        let calibratedAltitude = motionManager.deviceAltitude + alignmentOffsetAltitude
        
        let targetAzimuth = astronomyEngine.lastAzimuth
        let targetAltitude = astronomyEngine.lastAltitude
        
        guard targetAzimuth > 0 || targetAltitude > 0 else { return }
        
        let distance = AstronomyMath.angularDistance(
            alt1: calibratedAltitude,
            az1: calibratedAzimuth,
            alt2: targetAltitude,
            az2: targetAzimuth
        )
        
        let wasCentered = isTargetCentered
        let isNowCentered = distance < 5.0
        
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
