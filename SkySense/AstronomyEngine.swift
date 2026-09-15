import Foundation
import CoreLocation
import Combine

class AstronomyEngine: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var timer: Timer?
    
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
        // Run calculations every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.calculateJupiterPosition()
        }
        calculateJupiterPosition()
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    private func calculateJupiterPosition() {
        guard let location = locationManager?.location else { 
            print("Waiting for location...")
            return 
        }
        guard let jupiter = CelestialDatabase.getJupiter() else { return }
        
        let date = Date()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        let lst = AstronomyMath.localSiderealTime(date: date, longitude: lon)
        let coords = AstronomyMath.getAltAz(ra: jupiter.ra, dec: jupiter.dec, lat: lat, lst: lst)
        
        DispatchQueue.main.async {
            self.lastAzimuth = coords.az
            self.lastAltitude = coords.alt
        }
        
        print("Jupiter is currently at Azimuth \(String(format: "%.0f", coords.az))°, Altitude \(String(format: "%.0f", coords.alt))°.")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if timer == nil {
            calculateJupiterPosition() // Initial calculation once location is found
        }
    }
}
