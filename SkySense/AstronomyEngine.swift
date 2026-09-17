import Foundation
import CoreLocation
import Combine

struct TargetCoordinates {
    let object: CelestialObject
    let alt: Double
    let az: Double
}

class AstronomyEngine: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var timer: Timer?
    private var issLat: Double = 0.0
    private var issLon: Double = 0.0
    private var issAlt: Double = 415.0 // average km
    private var lastISSFetch: Date = Date.distantPast
    
    @Published var activeTargets: [TargetCoordinates] = []
    
    // For manual compatibility with old code
    @Published var lastAzimuth: Double = 0.0
    @Published var lastAltitude: Double = 0.0
    
    override init() {
        super.init()
        setupLocation()
    }
    
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func startTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.fetchISSPosition()
            self?.calculatePositions()
        }
        fetchISSPosition()
        calculatePositions()
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchISSPosition() {
        // Fetch every 15 seconds to avoid rate limits
        guard Date().timeIntervalSince(lastISSFetch) > 15.0 else { return }
        lastISSFetch = Date()
        
        guard let url = URL(string: "https://api.wheretheiss.at/v1/satellites/25544") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let lat = json["latitude"] as? Double,
                   let lon = json["longitude"] as? Double,
                   let alt = json["altitude"] as? Double {
                    DispatchQueue.main.async {
                        self?.issLat = lat
                        self?.issLon = lon
                        self?.issAlt = alt
                        self?.calculatePositions()
                    }
                }
            } catch {
                print("Failed to parse ISS data")
            }
        }.resume()
    }
    
    func calculatePositions() {
        guard let location = locationManager?.location else { return }
        let date = Date()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let lst = AstronomyMath.localSiderealTime(date: date, longitude: lon)
        
        let allObjects = CelestialDatabase.objects
        var newTargets: [TargetCoordinates] = []
        
        for baseObject in allObjects {
            var object = baseObject
            var finalAlt = 0.0
            var finalAz = 0.0
            
            if object.name == "ISS" {
                let altAz = SolarSystemMath.getSatelliteAltAz(obsLat: lat, obsLon: lon, satLat: issLat, satLon: issLon, satAltKm: issAlt)
                finalAlt = altAz.alt
                finalAz = altAz.az
                
                let apparentCoords = SolarSystemMath.getApparentRaDec(alt: finalAlt, az: finalAz, lat: lat, lst: lst)
                object.ra = apparentCoords.ra
                object.dec = apparentCoords.dec
                
            } else if object.name == "Moon" {
                let coords = SolarSystemMath.getMoonCoordinates(date: date)
                object.ra = coords.ra
                object.dec = coords.dec
                let altAz = AstronomyMath.getAltAz(ra: object.ra, dec: object.dec, lat: lat, lst: lst)
                finalAlt = altAz.alt
                finalAz = altAz.az
                
            } else if object.type == .planet {
                if let coords = SolarSystemMath.getPlanetCoordinates(planetName: object.name, date: date) {
                    object.ra = coords.ra
                    object.dec = coords.dec
                }
                let altAz = AstronomyMath.getAltAz(ra: object.ra, dec: object.dec, lat: lat, lst: lst)
                finalAlt = altAz.alt
                finalAz = altAz.az
                
            } else {
                // Stars use static RA/Dec
                let altAz = AstronomyMath.getAltAz(ra: object.ra, dec: object.dec, lat: lat, lst: lst)
                finalAlt = altAz.alt
                finalAz = altAz.az
            }
            
            newTargets.append(TargetCoordinates(object: object, alt: finalAlt, az: finalAz))
        }
        
        DispatchQueue.main.async {
            self.activeTargets = newTargets
            
            // Keep Jupiter for legacy phase code if needed, or update if user is looking for it
            if let jupiter = newTargets.first(where: { $0.object.name == "Jupiter" }) {
                self.lastAzimuth = jupiter.az
                self.lastAltitude = jupiter.alt
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if timer == nil {
            calculatePositions()
        }
    }
}
