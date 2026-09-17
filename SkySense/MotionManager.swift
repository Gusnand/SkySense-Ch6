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
            let rm = attitude.rotationMatrix
            
            // The back camera points in the -Z direction of the device's local frame.
            // We transform the local vector (0, 0, -1) to the world frame (.xTrueNorthZVertical).
            let vx = -rm.m13
            let vy = -rm.m23
            let vz = -rm.m33
            
            // Altitude is the angle above the horizontal plane
            let alt = asin(vz) * 180.0 / .pi
            
            // Azimuth is the angle from True North (+X) towards East (-Y)
            var az = atan2(-vy, vx) * 180.0 / .pi
            if az < 0 { az += 360.0 }
            
            self?.deviceAzimuth = az
            self?.deviceAltitude = alt
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
