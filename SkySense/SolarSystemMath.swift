import Foundation
import CoreLocation

enum SolarSystemMath {
    static func getJulianDate(_ date: Date) -> Double {
        return (date.timeIntervalSince1970 / 86400.0) + 2440587.5
    }
    
    static func getPlanetCoordinates(planetName: String, date: Date) -> (ra: Double, dec: Double)? {
        let jd = getJulianDate(date)
        let d = jd - 2451545.0
        
        var N, i, w, a, e, M: Double
        
        switch planetName.lowercased() {
        case "mercury":
            N = 48.3313 + 3.24587E-5 * d
            i = 7.0047 + 5.00E-8 * d
            w = 29.1241 + 1.01444E-5 * d
            a = 0.387098
            e = 0.205635 + 5.59E-10 * d
            M = 168.6562 + 4.0923344368 * d
        case "venus":
            N = 76.6799 + 2.46590E-5 * d
            i = 3.3946 + 2.75E-8 * d
            w = 54.8910 + 1.38374E-5 * d
            a = 0.723330
            e = 0.006773 - 1.302E-9 * d
            M = 48.0052 + 1.6021302244 * d
        case "mars":
            N = 49.5574 + 2.11081E-5 * d
            i = 1.8497 - 1.78E-8 * d
            w = 286.5016 + 2.92961E-5 * d
            a = 1.523688
            e = 0.093405 + 2.516E-9 * d
            M = 18.6021 + 0.5240207766 * d
        case "jupiter":
            N = 100.4542 + 2.76854E-5 * d
            i = 1.3030 - 1.557E-7 * d
            w = 273.8777 + 1.64505E-5 * d
            a = 5.20256
            e = 0.048498 + 4.469E-9 * d
            M = 19.8950 + 0.0830853001 * d
        case "saturn":
            N = 113.6634 + 2.38980E-5 * d
            i = 2.4886 - 1.081E-7 * d
            w = 339.3939 + 2.97661E-5 * d
            a = 9.55475
            e = 0.055546 - 9.499E-9 * d
            M = 316.9670 + 0.0334442282 * d
        case "uranus":
            N = 74.0005 + 1.3978E-5 * d
            i = 0.7733 + 1.9E-8 * d
            w = 96.6612 + 3.0565E-5 * d
            a = 19.18171 - 1.55E-8 * d
            e = 0.047318 + 7.45E-9 * d
            M = 142.5905 + 0.011725806 * d
        case "neptune":
            N = 131.7806 + 3.0173E-5 * d
            i = 1.7700 - 2.55E-7 * d
            w = 272.8461 - 6.027E-6 * d
            a = 30.05826 + 3.313E-8 * d
            e = 0.008606 + 2.15E-9 * d
            M = 260.2471 + 0.005995147 * d
        default: return nil
        }
        
        // Step A: Calculate the Heliocentric Cartesian coordinates (x, y, z) of the Target Planet for the current Julian Date.
        let E = computeEccentricAnomaly(M: M, e: e)
        let ERad = E * .pi / 180.0
        
        let xv = a * (cos(ERad) - e)
        let yv = a * (sqrt(1.0 - e * e) * sin(ERad))
        
        let v = atan2(yv, xv) * 180.0 / .pi
        let r = sqrt(xv * xv + yv * yv)
        
        let l = v + w
        let lRad = l * .pi / 180.0
        let NRad = N * .pi / 180.0
        let iRad = i * .pi / 180.0
        
        let xh = r * (cos(NRad) * cos(lRad) - sin(NRad) * sin(lRad) * cos(iRad))
        let yh = r * (sin(NRad) * cos(lRad) + cos(NRad) * sin(lRad) * cos(iRad))
        let zh = r * (sin(lRad) * sin(iRad))
        
        // Step B: Calculate the Heliocentric Cartesian coordinates (x, y, z) of the Earth for the current Julian Date.
        let e_a = 1.00000
        let e_e = 0.016709 - 1.151E-9 * d
        let e_M = 356.0470 + 0.9856002585 * d
        // Earth's longitude of perihelion is the Sun's longitude of perihelion (282.9404) minus 180 degrees.
        let e_w = 102.9404 + 4.70935E-5 * d
        
        let e_E = computeEccentricAnomaly(M: e_M, e: e_e)
        let e_ERad = e_E * .pi / 180.0
        
        let e_xv = e_a * (cos(e_ERad) - e_e)
        let e_yv = e_a * (sqrt(1.0 - e_e * e_e) * sin(e_ERad))
        let e_v = atan2(e_yv, e_xv) * 180.0 / .pi
        let e_r = sqrt(e_xv * e_xv + e_yv * e_yv)
        
        let e_l = e_v + e_w
        let e_lRad = e_l * .pi / 180.0
        let xe = e_r * cos(e_lRad)
        let ye = e_r * sin(e_lRad)
        let ze = 0.0
        
        // Step C (Geocentric Translation): Subtract Earth's coordinates from the Planet's coordinates.
        let xg = xh - xe
        let yg = yh - ye
        let zg = zh - ze
        
        // Step D (Ecliptic to Equatorial): Apply the Obliquity of the Ecliptic
        let ecl = 23.4393 - 3.563E-7 * d
        let eclRad = ecl * .pi / 180.0
        
        let xeq = xg
        let yeq = yg * cos(eclRad) - zg * sin(eclRad)
        let zeq = yg * sin(eclRad) + zg * cos(eclRad)
        
        var ra = atan2(yeq, xeq) * 180.0 / .pi
        let dec = atan2(zeq, sqrt(xeq * xeq + yeq * yeq)) * 180.0 / .pi
        
        if ra < 0 { ra += 360.0 }
        
        // Step E: Pass this correctly calculated RA/Dec back to the engine.
        return (ra: ra, dec: dec)
    }
    
    static func getMoonCoordinates(date: Date) -> (ra: Double, dec: Double) {
        let jd = getJulianDate(date)
        let d = jd - 2451545.0
        
        let N = 125.1228 - 0.0529538083 * d
        let i = 5.1454
        let w = 318.0634 + 0.1643573223 * d
        let a = 60.2666 // Earth radii
        let e = 0.054900
        let M = 115.3654 + 13.0649929509 * d
        
        let E = computeEccentricAnomaly(M: M, e: e)
        let ERad = E * .pi / 180.0
        
        let xv = a * (cos(ERad) - e)
        let yv = a * (sqrt(1.0 - e * e) * sin(ERad))
        
        let v = atan2(yv, xv) * 180.0 / .pi
        let r = sqrt(xv * xv + yv * yv)
        
        let l = v + w
        let lRad = l * .pi / 180.0
        let NRad = N * .pi / 180.0
        let iRad = i * .pi / 180.0
        
        let xh = r * (cos(NRad) * cos(lRad) - sin(NRad) * sin(lRad) * cos(iRad))
        let yh = r * (sin(NRad) * cos(lRad) + cos(NRad) * sin(lRad) * cos(iRad))
        let zh = r * (sin(lRad) * sin(iRad))
        
        let ecl = 23.4393 - 3.563E-7 * d
        let eclRad = ecl * .pi / 180.0
        
        let xeq = xh
        let yeq = yh * cos(eclRad) - zh * sin(eclRad)
        let zeq = yh * sin(eclRad) + zh * cos(eclRad)
        
        var ra = atan2(yeq, xeq) * 180.0 / .pi
        let dec = atan2(zeq, sqrt(xeq * xeq + yeq * yeq)) * 180.0 / .pi
        
        if ra < 0 { ra += 360.0 }
        
        return (ra: ra, dec: dec)
    }
    
    private static func computeEccentricAnomaly(M: Double, e: Double) -> Double {
        var mNorm = M.truncatingRemainder(dividingBy: 360.0)
        if mNorm < 0 { mNorm += 360.0 }
        let mRad = mNorm * .pi / 180.0
        
        var E0 = mRad + e * sin(mRad) * (1.0 + e * cos(mRad))
        var E1 = E0
        for _ in 0..<10 {
            E1 = E0 - (E0 - e * sin(E0) - mRad) / (1.0 - e * cos(E0))
            if abs(E1 - E0) < 1e-6 { break }
            E0 = E1
        }
        return E1 * 180.0 / .pi
    }
    
    // Calculates Alt/Az of a satellite from observer
    static func getSatelliteAltAz(obsLat: Double, obsLon: Double, satLat: Double, satLon: Double, satAltKm: Double) -> (alt: Double, az: Double) {
        let R = 6371.0 // Earth radius in km
        
        let obsLatRad = obsLat * .pi / 180.0
        let obsLonRad = obsLon * .pi / 180.0
        let ox = R * cos(obsLatRad) * cos(obsLonRad)
        let oy = R * cos(obsLatRad) * sin(obsLonRad)
        let oz = R * sin(obsLatRad)
        
        let satLatRad = satLat * .pi / 180.0
        let satLonRad = satLon * .pi / 180.0
        let rSat = R + satAltKm
        let ix = rSat * cos(satLatRad) * cos(satLonRad)
        let iy = rSat * cos(satLatRad) * sin(satLonRad)
        let iz = rSat * sin(satLatRad)
        
        let dx = ix - ox
        let dy = iy - oy
        let dz = iz - oz
        
        let slon = sin(obsLonRad), clon = cos(obsLonRad)
        let slat = sin(obsLatRad), clat = cos(obsLatRad)
        
        let e = -slon * dx + clon * dy
        let n = -slat * clon * dx - slat * slon * dy + clat * dz
        let u = clat * clon * dx + clat * slon * dy + slat * dz
        
        let dist = sqrt(e*e + n*n + u*u)
        let altRad = asin(u / dist)
        var azRad = atan2(e, n)
        if azRad < 0 { azRad += 2 * .pi }
        
        return (alt: altRad * 180.0 / .pi, az: azRad * 180.0 / .pi)
    }
    
    // Calculates apparent RA/Dec for an object given its Alt/Az
    static func getApparentRaDec(alt: Double, az: Double, lat: Double, lst: Double) -> (ra: Double, dec: Double) {
        let altRad = alt * .pi / 180.0
        let azRad = az * .pi / 180.0
        let latRad = lat * .pi / 180.0
        
        let sinDec = sin(altRad) * sin(latRad) + cos(altRad) * cos(latRad) * cos(azRad)
        let decRad = asin(sinDec)
        let dec = decRad * 180.0 / .pi
        
        let cosHA = (sin(altRad) - sin(decRad) * sin(latRad)) / (cos(decRad) * cos(latRad))
        var haRad = acos(max(-1.0, min(1.0, cosHA)))
        
        if sin(azRad) > 0 {
            haRad = 2 * .pi - haRad
        }
        
        var ra = lst - (haRad * 180.0 / .pi)
        ra = ra.truncatingRemainder(dividingBy: 360.0)
        if ra < 0 { ra += 360.0 }
        
        return (ra: ra, dec: dec)
    }
}
