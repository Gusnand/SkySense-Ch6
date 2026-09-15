import SwiftUI

struct ContentView: View {
    @StateObject private var engine = AstronomyEngine()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SkySense Engine")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Jupiter Position:")
                .font(.headline)
            
            Text("Azimuth: \(engine.lastAzimuth, specifier: "%.1f")°")
            Text("Altitude: \(engine.lastAltitude, specifier: "%.1f")°")
            
            Text("Check XCode Console for printed output.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 20)
        }
        .padding()
        .onAppear {
            engine.startTracking()
        }
        .onDisappear {
            engine.stopTracking()
        }
    }
}

#Preview {
    ContentView()
}
