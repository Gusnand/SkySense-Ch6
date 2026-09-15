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
            self?.calculatePositions()
        }
        calculatePositions()
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    func calculatePositions() {
        guard let location = locationManager?.location else { return }
        let date = Date()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let lst = AstronomyMath.localSiderealTime(date: date, longitude: lon)
        
        let allObjects = CelestialDatabase.objects
        var newTargets: [TargetCoordinates] = []
        
        for object in allObjects {
            let coords = AstronomyMath.getAltAz(ra: object.ra, dec: object.dec, lat: lat, lst: lst)
            // Optional: Filter objects below horizon if desired, but for now we track them all.
            newTargets.append(TargetCoordinates(object: object, alt: coords.alt, az: coords.az))
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
