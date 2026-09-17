import SwiftUI
import CoreMotion
import simd
import Combine

struct ContentView: View {
    @StateObject private var astronomyEngine = AstronomyEngine()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var hapticManager = HapticManager()
    
    @State private var selectedFilter: CelestialObjectType = .planet
    @State private var selectedCelestialObject: CelestialObject?
    @State private var selectedDetent: PresentationDetent = .fraction(0.4)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Raw Camera Background
                CameraPreviewView(session: cameraManager.session)
                    .edgesIgnoringSafeArea(.all)
                
                // 2. 3D AR Projections
                if let rm = motionManager.rotationMatrix {
                    let filteredTargets = astronomyEngine.activeTargets.filter { $0.object.type == selectedFilter }
                    
                    // Render dots for all targets in FOV
                    ForEach(filteredTargets, id: \.object.id) { target in
                        if let point = AstronomyMath.project(alt: target.alt, az: target.az, rm: rm, screenSize: geometry.size) {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 8, height: 8)
                                .shadow(color: .white, radius: 4)
                                .position(point)
                            
                            Text(target.object.name)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .position(x: point.x, y: point.y - 15)
                        }
                    }
                    
                    // Nearest Target logic
                    if let nearest = getNearestTarget(targets: filteredTargets, rm: rm) {
                        let vec = getDeviceVector(alt: nearest.alt, az: nearest.az, rm: rm)
                        let isLocked = isTargetLocked(target: nearest, rm: rm, size: geometry.size)
                        
                        if isLocked {
                            // TARGET IN FOV -> Render the "Locked" Tooltip
                            VStack {
                                Spacer()
                                Button(action: {
                                    selectedCelestialObject = nearest.object
                                }) {
                                    VStack(spacing: 4) {
                                        Text(nearest.object.name)
                                            .font(.headline).bold()
                                            .foregroundColor(.white)
                                        Text("Tap to learn more")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .liquidGlass()
                                }
                                Spacer()
                            }
                        } else {
                            // TARGET OFF CENTER -> Render Directional Edge Arrow
                            // In screen space: +X is right, +Y is DOWN (so device +Y is screen -Y)
                            let angle = atan2(-vec.dy, vec.dx)
                            
                            Image(systemName: "location.north.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .shadow(color: .white, radius: 5)
                                // Arrow points UP normally. Rotate it +90 to point RIGHT (0 radians)
                                .rotationEffect(.radians(angle + .pi / 2.0))
                                .offset(x: cos(angle) * 125, y: sin(angle) * 125)
                        }
                    }
                }
                
                // 3. Heads Up UI Overlay
                VStack {
                    // Top Empty space / status
                    HStack {
                        VStack(alignment: .leading) {
                            Text("3D AR Tracking Active")
                                .font(.caption).bold().foregroundColor(.green)
                        }
                        .padding()
                        .padding(.top, 50)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Reticle / Crosshair in Center
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .stroke(.white.opacity(0.1), lineWidth: 4)
                            .frame(width: 230, height: 230)
                    }
                    
                    Spacer()
                    
                    // Bottom HUD (Category Pills and Toggle)
                    HStack(spacing: 16) {
                        CameraModeSelectorView(selectedFilter: $selectedFilter)
                            .frame(maxWidth: .infinity)
                        
                        // Night Vision Toggle
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            cameraManager.isNightVisionEnabled.toggle()
                        }) {
                            Image(systemName: cameraManager.isNightVisionEnabled ? "moon.stars.fill" : "moon")
                                .font(.title3)
                                .foregroundColor(cameraManager.isNightVisionEnabled ? .yellow : .white)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(LinearGradient(colors: [.white.opacity(0.5), .clear, .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .preferredColorScheme(.dark)
            .colorMultiply(cameraManager.isNightVisionEnabled ? .red : .white)
            .animation(.easeInOut, value: cameraManager.isNightVisionEnabled)
            .onAppear {
                astronomyEngine.startTracking()
                motionManager.start()
            }
            .onDisappear {
                astronomyEngine.stopTracking()
                motionManager.stop()
                hapticManager.pause()
            }
            .onChange(of: motionManager.deviceAzimuth) { updateSensoryEngine(geometry: geometry) }
            .onChange(of: selectedFilter) { updateSensoryEngine(geometry: geometry) }
            .sheet(item: $selectedCelestialObject) { object in
                CelestialStorySheet(object: object, selectedDetent: $selectedDetent)
                    .presentationBackground(.ultraThinMaterial)
                    .preferredColorScheme(.dark)
                    .presentationDetents([.fraction(0.4), .large], selection: $selectedDetent)
                    .presentationDragIndicator(.visible)
                    .colorMultiply(cameraManager.isNightVisionEnabled ? .red : .white)
                    .animation(.easeInOut, value: cameraManager.isNightVisionEnabled)
                    .onAppear {
                        cameraManager.pause()
                        hapticManager.pause()
                    }
                    .onDisappear {
                        cameraManager.resume()
                        selectedDetent = .fraction(0.4)
                    }
            }
        }
    }
    
    private func getDeviceVector(alt: Double, az: Double, rm: CMRotationMatrix) -> (dx: Double, dy: Double, dz: Double) {
        let altRad = alt * .pi / 180.0
        let azRad = az * .pi / 180.0
        
        let worldX = cos(altRad) * cos(azRad)
        let worldY = -cos(altRad) * sin(azRad)
        let worldZ = sin(altRad)
        
        let worldVector = SIMD3<Double>(worldX, worldY, worldZ)
        let deviceVector = rm.simd3x3 * worldVector
        
        let localX = deviceVector.x
        let localY = deviceVector.y
        let localZ = -deviceVector.z
        
        let orientation = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.effectiveGeometry.interfaceOrientation ?? .portrait
        
        var adjX = localX
        var adjY = localY
        
        switch orientation {
        case .landscapeLeft:
            adjX = -localY
            adjY = localX
        case .landscapeRight:
            adjX = localY
            adjY = -localX
        case .portraitUpsideDown:
            adjX = -localX
            adjY = -localY
        default:
            break
        }
        
        return (dx: adjX, dy: adjY, dz: localZ)
    }
    
    // Finds the target that is closest to the center of the camera (-Z axis).
    private func getNearestTarget(targets: [TargetCoordinates], rm: CMRotationMatrix) -> TargetCoordinates? {
        guard !targets.isEmpty else { return nil }
        
        // The most positive `dz` means the vector is most closely aligned with the camera axis.
        return targets.max { a, b in
            let vecA = getDeviceVector(alt: a.alt, az: a.az, rm: rm)
            let vecB = getDeviceVector(alt: b.alt, az: b.az, rm: rm)
            return vecA.dz < vecB.dz
        }
    }
    
    private func isTargetLocked(target: TargetCoordinates, rm: CMRotationMatrix, size: CGSize) -> Bool {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        if let point = AstronomyMath.project(alt: target.alt, az: target.az, rm: rm, screenSize: size) {
            let dist = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
            return dist < 80.0
        }
        return false
    }
    
    private func updateSensoryEngine(geometry: GeometryProxy) {
        guard let rm = motionManager.rotationMatrix else { return }
        let filteredTargets = astronomyEngine.activeTargets.filter { $0.object.type == selectedFilter }
        
        guard let nearest = getNearestTarget(targets: filteredTargets, rm: rm) else {
            hapticManager.updateHapticFeedback(distance: 999)
            return
        }
        
        // Convert the 3D angular alignment into an abstract distance for haptics.
        // `dz` is the cosine of the angle between the target and the camera axis.
        // theta = acos(dz). We multiply by 180/pi to get degrees.
        let vec = getDeviceVector(alt: nearest.alt, az: nearest.az, rm: rm)
        let clampedDz = max(-1.0, min(1.0, vec.dz))
        let angularDist = acos(clampedDz) * 180.0 / .pi
        
        hapticManager.updateHapticFeedback(distance: angularDist)
    }
}


struct CelestialStorySheet: View {
    let object: CelestialObject
    @Binding var selectedDetent: PresentationDetent
    @Environment(\.dismiss) var dismiss
    
    @State private var isDoYouKnowExpanded = true
    @State private var isFunFactExpanded = true
    
    var body: some View {
        let content = CelestialContentDatabase.content.first { $0.name == object.name }
        let topSubtitle = object.storyDescription.components(separatedBy: ".").first ?? "Unknown"
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: selectedDetent == .large ? 24 : 12) {
                // Top Bar
                ZStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    
                    VStack(spacing: 4) {
                        Text(object.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(topSubtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.top, 10)
                
                // Image
                let imageSize: CGFloat = selectedDetent == .large ? 240 : 130
                
                if let uiImage = UIImage(named: object.name.lowercased()) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.5), radius: 20)
                } else if let urlString = CelestialImageHelper.imageURL(for: object.name) {
                    CachedAsyncImage(
                        url: urlString,
                        imageSize: imageSize,
                        placeholder: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: imageSize, height: imageSize)
                                ProgressView()
                                    .tint(.white)
                            }
                            .shadow(color: .black.opacity(0.5), radius: 20)
                        },
                        fallback: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: imageSize, height: imageSize)
                                    .shadow(color: .black.opacity(0.5), radius: 20)
                                
                                Image(systemName: object.type == .planet ? "globe" : (object.type == .satellite ? "moon.circle" : "sparkles"))
                                    .font(.system(size: imageSize / 3))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    )
                } else {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: imageSize, height: imageSize)
                            .shadow(color: .black.opacity(0.5), radius: 20)
                        
                        Image(systemName: object.type == .planet ? "globe" : (object.type == .satellite ? "moon.circle" : "sparkles"))
                            .font(.system(size: imageSize / 3))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                // Persona
                VStack(spacing: 12) {
                    Text("Persona")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.5))
                    
                    if let persona = content?.personaSubtitle {
                        Text("\"\(persona)\"")
                            .font(.title3.italic().weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    } else {
                        Text("\"\(object.storyDescription)\"")
                            .font(.title3.italic().weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                // Conditional Content for .large detent only
                if selectedDetent == .large {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // Bio
                        if let content = content {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Bio")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                bioRow(title: "Stat 1", value: content.stat1)
                                bioRow(title: "Stat 2", value: content.stat2)
                                bioRow(title: "Stat 3", value: content.stat3)
                            }
                        }
                        
                        // Do you Know?
                        if let myth = content?.mythParagraph {
                            accordionSection(title: "Do you Know?", content: myth, isExpanded: $isDoYouKnowExpanded)
                        }
                        
                        // Fun Fact
                        if let reality = content?.realityParagraph {
                            accordionSection(title: "Fun Fact about \(object.name)", content: reality, isExpanded: $isFunFactExpanded)
                        }
                    }
                    .padding(.top, 20)
                    .transition(.opacity) // Smooth transition when sheet expands
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .animation(.default, value: selectedDetent)
    }
    
    private func bioRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    private func accordionSection(title: String, content: String, isExpanded: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation { isExpanded.wrappedValue.toggle() }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? 180 : 0))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            if isExpanded.wrappedValue {
                Text(content)
                    .font(.body)
                    .italic()
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct CameraModeSelectorView: View {
    @Binding var selectedFilter: CelestialObjectType
    
    let filters: [(type: CelestialObjectType, name: String, icon: String)] = [
        (.planet, "Planets", "globe"),
        (.star, "Stars", "sparkles"),
        (.satellite, "Satellites", "satellite")
    ]
    
    var scrollBinding: Binding<CelestialObjectType?> {
        Binding(
            get: { selectedFilter },
            set: { if let val = $0 { selectedFilter = val } }
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    ForEach(filters, id: \.type) { filter in
                        HStack(spacing: 6) {
                            if selectedFilter == filter.type {
                                Image(systemName: filter.icon)
                            } else {
                                Image(systemName: filter.icon)
                                    .opacity(0.5)
                            }
                            Text(filter.name)
                                .font(.system(size: 16, weight: selectedFilter == filter.type ? .semibold : .regular))
                        }
                        .foregroundColor(selectedFilter == filter.type ? .yellow : .white.opacity(0.6))
                        .id(filter.type)
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = filter.type
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, max(0, (geo.size.width / 2) - 60))
            }
            .scrollPosition(id: scrollBinding, anchor: .center)
            .scrollTargetBehavior(.viewAligned)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(LinearGradient(colors: [.white.opacity(0.5), .clear, .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
            )
            .mask(
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.15),
                    .init(color: .black, location: 0.85),
                    .init(color: .clear, location: 1)
                ], startPoint: .leading, endPoint: .trailing)
            )
        }
        .frame(height: 50)
    }
}

#Preview {
    ContentView()
}

// MARK: - Image Caching & Fetching

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

enum ImageLoadState {
    case loading
    case success(UIImage)
    case failure
}

class ImageLoader: ObservableObject {
    @Published var state: ImageLoadState = .loading
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        loadImage()
    }
    
    func loadImage() {
        if let cachedImage = ImageCache.shared.object(forKey: urlString as NSString) {
            self.state = .success(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            self.state = .failure
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                ImageCache.shared.setObject(downloadedImage, forKey: self.urlString as NSString)
                DispatchQueue.main.async {
                    self.state = .success(downloadedImage)
                }
            } else {
                DispatchQueue.main.async {
                    self.state = .failure
                }
            }
        }.resume()
    }
}

struct CachedAsyncImage<Placeholder: View, Fallback: View>: View {
    @StateObject private var loader: ImageLoader
    let imageSize: CGFloat
    let placeholder: Placeholder
    let fallback: Fallback
    
    init(url: String, imageSize: CGFloat, @ViewBuilder placeholder: () -> Placeholder, @ViewBuilder fallback: () -> Fallback) {
        _loader = StateObject(wrappedValue: ImageLoader(urlString: url))
        self.imageSize = imageSize
        self.placeholder = placeholder()
        self.fallback = fallback()
    }
    
    var body: some View {
        switch loader.state {
        case .loading:
            placeholder
        case .success(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.5), radius: 20)
        case .failure:
            fallback
        }
    }
}

struct CelestialImageHelper {
    static let urls: [String: String] = [
        "Moon": "https://upload.wikimedia.org/wikipedia/commons/e/e1/FullMoon2010.jpg",
        "Mercury": "https://upload.wikimedia.org/wikipedia/commons/4/4a/Mercury_in_true_color.jpg",
        "Venus": "https://upload.wikimedia.org/wikipedia/commons/e/e5/Venus-real_color.jpg",
        "Earth": "https://upload.wikimedia.org/wikipedia/commons/9/97/The_Earth_seen_from_Apollo_17.jpg",
        "Mars": "https://upload.wikimedia.org/wikipedia/commons/0/02/OSIRIS_Mars_true_color.jpg",
        "Jupiter": "https://upload.wikimedia.org/wikipedia/commons/e/e2/Jupiter.jpg",
        "Saturn": "https://upload.wikimedia.org/wikipedia/commons/c/c7/Saturn_during_Equinox.jpg",
        "Uranus": "https://upload.wikimedia.org/wikipedia/commons/3/3d/Uranus2.jpg",
        "Neptune": "https://upload.wikimedia.org/wikipedia/commons/6/63/Neptune_-_Voyager_2_%2829347980845%29_flatten_crop.jpg",
        "Sirius": "https://upload.wikimedia.org/wikipedia/commons/c/cb/Sirius_A_and_B_Hubble_photo.jpg",
        "Betelgeuse": "https://upload.wikimedia.org/wikipedia/commons/5/5c/Betelgeuse_captured_by_ALMA.jpg",
        "ISS": "https://upload.wikimedia.org/wikipedia/commons/0/04/International_Space_Station_after_undocking_of_STS-132.jpg"
    ]
    
    static func imageURL(for name: String) -> String? {
        return urls[name]
    }
}
