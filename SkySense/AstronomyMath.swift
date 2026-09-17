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
        
        // 1. Calculate Celestial Vector
        let east = cos(altRad) * sin(azRad)
        let north = cos(altRad) * cos(azRad)
        let up = sin(altRad)
        
        // 2. Map to CoreMotion World Reference (X: North, Y: West, Z: Up)
        let worldX = north
        let worldY = -east
        let worldZ = up
        
        // 3. Apply Device Attitude Matrix (inverse)
        let localX = rm.m11 * worldX + rm.m21 * worldY + rm.m31 * worldZ
        let localY = rm.m12 * worldX + rm.m22 * worldY + rm.m32 * worldZ
        let localZ = -(rm.m13 * worldX + rm.m23 * worldY + rm.m33 * worldZ)
        
        // 3. Behind-Camera Clipping
        if localZ < 0 { return nil }
        
        // 4. Uniform Trigonometric 2D Projection
        let fov = 60.0 * .pi / 180.0
        let focalLength = max(screenSize.width, screenSize.height) / (2.0 * tan(fov / 2.0))
        
        let screenX = (screenSize.width / 2.0) + (localX / localZ) * focalLength
        let screenY = (screenSize.height / 2.0) - (localY / localZ) * focalLength
        
        return CGPoint(x: screenX, y: screenY)
    }
}
