import Foundation
import CoreLocation
import CoreMotion

enum AstronomyMath {
    
    static func localSiderealTime(date: Date, longitude: Double) -> Double {
        let jd = (date.timeIntervalSince1970 / 86400.0) + 2440587.5
        let t = (jd - 2451545.0) / 36525.0
        var gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0
        gmst = gmst.truncatingRemainder(dividingBy: 360.0)
        if gmst < 0 { gmst += 360.0 }
        
        var lst = gmst + longitude
        lst = lst.truncatingRemainder(dividingBy: 360.0)
        if lst < 0 { lst += 360.0 }
        return lst
    }
    
    static func getAltAz(ra: Double, dec: Double, lat: Double, lst: Double) -> (alt: Double, az: Double) {
        var ha = lst - ra
        ha = ha.truncatingRemainder(dividingBy: 360.0)
        if ha < 0 { ha += 360.0 }
        
        let haRad = ha * .pi / 180.0
        let decRad = dec * .pi / 180.0
        let latRad = lat * .pi / 180.0
        
        let sinAlt = sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad)
        let altRad = asin(sinAlt)
        let altitude = altRad * 180.0 / .pi
        
        let cosAz = (sin(decRad) - sin(latRad) * sin(altRad)) / (cos(latRad) * cos(altRad))
        var azRad = acos(max(-1.0, min(1.0, cosAz)))
        
        if sin(haRad) > 0 {
            azRad = 2 * .pi - azRad
        }
        let azimuth = azRad * 180.0 / .pi
        
        return (alt: altitude, az: azimuth)
    }
    
    static func angularDistance(alt1: Double, az1: Double, alt2: Double, az2: Double) -> Double {
        let a1 = alt1 * .pi / 180.0
        let z1 = az1 * .pi / 180.0
        let a2 = alt2 * .pi / 180.0
        let z2 = az2 * .pi / 180.0
        
        let cosD = sin(a1) * sin(a2) + cos(a1) * cos(a2) * cos(z1 - z2)
        let dRad = acos(max(-1.0, min(1.0, cosD)))
        return dRad * 180.0 / .pi
    }
    
    /// Projects a celestial object's Alt/Az onto the 2D screen using the device's rotation matrix.
    static func project(alt: Double, az: Double, rm: CMRotationMatrix, screenSize: CGSize) -> CGPoint? {
        let altRad = alt * .pi / 180.0
        let azRad = az * .pi / 180.0
        
        // 1. Convert spherical Alt/Az to Cartesian world coordinates
        // Reference frame: X = True North, Y = West, Z = Up
        let w_x = cos(altRad) * cos(azRad)
        let w_y = -cos(altRad) * sin(azRad)
        let w_z = sin(altRad)
        
        // 2. Transform world coordinates to device coordinates
        // The rotation matrix (rm) transforms from device to world.
        // To go from world to device, we multiply by the inverse (transpose) of rm.
        let d_x = rm.m11 * w_x + rm.m21 * w_y + rm.m31 * w_z
        let d_y = rm.m12 * w_x + rm.m22 * w_y + rm.m32 * w_z
        let d_z = rm.m13 * w_x + rm.m23 * w_y + rm.m33 * w_z
        
        // The device camera points along the -Z axis.
        // If the object's Z coordinate is >= 0, it is behind the camera (not visible).
        if d_z >= 0 { return nil }
        
        // 3. Project onto 2D screen (Pinhole camera model)
        // A typical iPhone wide camera has a diagonal FOV around 65-70 degrees.
        // Using focal length f ~ screenSize.height * 0.9 provides a good estimation.
        let f = screenSize.height * 0.9
        
        // d_x is right (+X), d_y is up (+Y).
        // On iOS screens, +X is right, but +Y is DOWN.
        let screenX = (screenSize.width / 2.0) + (d_x / -d_z) * f
        let screenY = (screenSize.height / 2.0) - (d_y / -d_z) * f
        
        return CGPoint(x: screenX, y: screenY)
    }
}
