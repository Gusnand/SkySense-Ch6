import Foundation
import CoreLocation

enum AstronomyMath {
    
    /// Calculate Local Sidereal Time (LST) in degrees.
    /// - Parameters:
    ///   - date: Current UTC date.
    ///   - longitude: Device longitude in degrees.
    /// - Returns: LST in degrees (0 to 360).
    static func localSiderealTime(date: Date, longitude: Double) -> Double {
        // Julian Date calculation
        let jd = (date.timeIntervalSince1970 / 86400.0) + 2440587.5
        
        let t = (jd - 2451545.0) / 36525.0
        
        // Greenwich Mean Sidereal Time (GMST) at 0h UT in degrees
        var gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0
        
        gmst = gmst.truncatingRemainder(dividingBy: 360.0)
        if gmst < 0 { gmst += 360.0 }
        
        // LST is GMST + longitude
        var lst = gmst + longitude
        lst = lst.truncatingRemainder(dividingBy: 360.0)
        if lst < 0 { lst += 360.0 }
        
        return lst
    }
    
    /// Convert Equatorial Coordinates (RA/Dec) to Horizontal Coordinates (Altitude/Azimuth)
    /// - Parameters:
    ///   - ra: Right Ascension in degrees.
    ///   - dec: Declination in degrees.
    ///   - lat: Device latitude in degrees.
    ///   - lst: Local Sidereal Time in degrees.
    /// - Returns: Tuple of Altitude and Azimuth in degrees.
    static func getAltAz(ra: Double, dec: Double, lat: Double, lst: Double) -> (alt: Double, az: Double) {
        // Hour Angle in degrees
        var ha = lst - ra
        ha = ha.truncatingRemainder(dividingBy: 360.0)
        if ha < 0 { ha += 360.0 }
        
        let haRad = ha * .pi / 180.0
        let decRad = dec * .pi / 180.0
        let latRad = lat * .pi / 180.0
        
        // Altitude
        let sinAlt = sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad)
        let altRad = asin(sinAlt)
        let altitude = altRad * 180.0 / .pi
        
        // Azimuth
        let cosAz = (sin(decRad) - sin(latRad) * sin(altRad)) / (cos(latRad) * cos(altRad))
        var azRad = acos(max(-1.0, min(1.0, cosAz))) // Clamp between -1 and 1
        
        if sin(haRad) > 0 {
            azRad = 2 * .pi - azRad
        }
        
        let azimuth = azRad * 180.0 / .pi
        
        return (alt: altitude, az: azimuth)
    }
}
