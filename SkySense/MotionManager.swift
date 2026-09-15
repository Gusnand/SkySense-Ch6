import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var deviceAzimuth: Double = 0.0
    @Published var deviceAltitude: Double = 0.0
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60fps
        
        // .xTrueNorthZVertical lets yaw align with true north
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { [weak self] data, error in
            guard let data = data else { return }
            
            let attitude = data.attitude
            
            // Map Yaw to Azimuth (0-360)
            // In CoreMotion, yaw is counter-clockwise? Let's normalize it to standard compass azimuth.
            var az = -attitude.yaw * 180.0 / .pi
            if az < 0 { az += 360.0 }
            
            // Map Pitch to Altitude (-90 to 90)
            // Simplistic mapping for holding phone in portrait orientation
            let alt = attitude.pitch * 180.0 / .pi
            
            self?.deviceAzimuth = az
            self?.deviceAltitude = alt
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
