import SwiftUI
import SwiftData
import MapKit

// MARK: - Map Display Configuration

private enum MapDisplayMode {
    case customWorldMap  // Option 1: Custom minimalist world map
    case nativeMap       // Option 2: Native SwiftUI Map
}

// Toggle this to switch between map modes
private let currentMapMode: MapDisplayMode = .nativeMap

struct CitiesView: View {
    @Environment(\.tabBarVisible) private var tabBarVisible
    @Query(sort: \City.name) private var allCities: [City]
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showingAllCities = false
    @State private var selectedCity: City?
    @State private var showingCityDetail = false
    
    private var visitedCities: [City] {
        allCities.filter { $0.isVisited }
    }
    
    private var cityAnnotations: [CityAnnotation] {
        visitedCities.map { CityAnnotation(city: $0) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            tabBarVisible.wrappedValue = true
                        }) {
                            Image(systemName: "chevron.left")
                                .font(AppFonts.icon)
                                .foregroundStyle(AppColors.icon)
                                .contentShape(Rectangle()) // Ensure entire frame is tappable
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(AppFonts.icon)
                                .foregroundStyle(AppColors.icon)
                                .contentShape(Rectangle()) // Ensure entire frame is tappable
                        }
                    }
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                    .padding(.top, AppSpacing.pageTop)
                    .background(AppColors.background) // Add background to block gestures below
                    .zIndex(1) // Ensure header is above map gestures
                        
                        // Title
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Cities")
                                .font(AppFonts.title)
                                .foregroundStyle(AppColors.titleText)
                            
                            Text("\(visitedCities.count) \(visitedCities.count == 1 ? "city" : "cities")")
                                .font(AppFonts.body)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                        .padding(.top, AppSpacing.sectionTop)
                        .padding(.bottom, AppSpacing.sectionBottom)
                        
                        // Map view - switches based on currentMapMode
                        Group {
                            switch currentMapMode {
                            case .customWorldMap:
                                customWorldMapView
                            case .nativeMap:
                                nativeMapView
                            }
                        }
                        .frame(maxHeight: 600)
                        
                        // View all cities button
                        Button {
                            showingAllCities = true
                        } label: {
                            HStack(spacing: AppSpacing.md) {
                                Text("View all cities")
                                    .font(CityDetailStyles.addButtonText)
                                
                                Image(systemName: "chevron.right")
                                    .font(CityDetailStyles.addButtonIcon)
                            }
                            .foregroundStyle(AppColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppDimensions.buttonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: AppDimensions.radiusLG)
                                    .fill(AppColors.cardBackground)
                            )
                        }
                        .padding(.top, 16)
                    }
                }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showingCityDetail) {
                if let city = selectedCity {
                    CityDetailView(city: city)
                }
            }
            .fullScreenCover(isPresented: $showingAllCities) {
                AllCitiesListView(cities: allCities)
            }
            .onChange(of: showingAllCities) { oldValue, newValue in
                // When All Cities view is dismissed, ensure tab bar stays hidden
                if !newValue {
                    tabBarVisible.wrappedValue = false
                }
            }
            .onAppear {
                tabBarVisible.wrappedValue = false
            }
        }
    }
    
    // MARK: - Map Views
    
    // Option 1: Custom world map with minimalist design
    private var customWorldMapView: some View {
        ZStack {
            // Map background
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.98, green: 0.98, blue: 0.99))
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
            
            // Simple world map silhouette
            MinimalistWorldMapView(cities: cityAnnotations) { city in
                selectedCity = city
                showingCityDetail = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .padding(.horizontal, 20)
        .aspectRatio(1.25, contentMode: .fit)
    }
    
    // Option 2: Native SwiftUI Map
    private var nativeMapView: some View {
        Map(position: $cameraPosition) {
            ForEach(cityAnnotations) { annotation in
                Annotation(annotation.city.localizedName(language: selectedLanguage), coordinate: annotation.coordinate) {
                    Button(action: {
                        selectedCity = annotation.city
                        showingCityDetail = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(annotation.markerColor)
                                .frame(width: 12, height: 12)
                                .shadow(color: annotation.markerColor.opacity(0.5), radius: 2)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        .padding(.horizontal, 20)
        .onAppear {
            // Set initial camera position to show all cities
            if !visitedCities.isEmpty {
                let coordinates = cityAnnotations.map { $0.coordinate }
                let region = calculateRegion(for: coordinates)
                cameraPosition = .region(region)
            }
        }
    }
    
    // Helper to calculate region that fits all cities
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
            )
        }
        
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5, // Add 50% padding
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - City List Row

private struct CityListRow: View {
    let city: City
    
    // Uniform marker color for all cities
    private var markerColor: Color {
        return AppColors.accent
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(markerColor)
                .frame(width: 8, height: 8)
            
            Text(city.name)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
        }
    }
}

// MARK: - City Annotation

private struct CityAnnotation: Identifiable {
    let id = UUID()
    let city: City
    
    // Default coordinates for demo (you'd want to add actual coordinates to City model)
    var coordinate: CLLocationCoordinate2D {
        switch city.name {
        case "Tokyo":
            return CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
        case "Paris":
            return CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        case "New York":
            return CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        case "Shanghai":
            return CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737)
        case "Beijing":
            return CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
        case "Shenzhen":
            return CLLocationCoordinate2D(latitude: 22.5431, longitude: 114.0579)
        default:
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
    
    // Uniform marker color for all cities
    var markerColor: Color {
        return AppColors.accent
    }
}

// MARK: - Minimalist World Map View

private struct MinimalistWorldMapView: View {
    let cities: [CityAnnotation]
    var onCityTap: ((City) -> Void)? = nil
    
    @State private var scale: CGFloat = 1.2
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // World map background image
            if let worldMapImage = UIImage(named: "world-map") {
                Image(uiImage: worldMapImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(MapStyles.imageOpacity)
            } else {
                // Fallback
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color(red: 0.88, green: 0.9, blue: 0.88))
                    .opacity(0.3)
                    .padding(40)
            }
            
            // City markers overlay (these also need to scale/offset with map)
            GeometryReader { geometry in
                ForEach(cities) { cityAnnotation in
                    let normalizedX = cityAnnotation.normalizedX(in: geometry.size)
                    let normalizedY = cityAnnotation.normalizedY(in: geometry.size)
                    
                    Button(action: {
                        onCityTap?(cityAnnotation.city)
                    }) {
                        CityMarker(color: cityAnnotation.markerColor)
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: geometry.size.width * normalizedX,
                        y: geometry.size.height * normalizedY
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scaleEffect(scale)
        .offset(offset)
        .overlay(alignment: .bottomTrailing) {
                // Zoom controls
                HStack(spacing: 12) {
                    // Zoom out button
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            let newScale = max(scale - 0.5, 1.0)
                            scale = newScale
                            // Reset offset if we're back to 1.0
                            if newScale == 1.0 {
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                            )
                    }
                    .disabled(scale <= 1.0)
                    .opacity(scale <= 1.0 ? 0.5 : 1.0)
                    
                    // Zoom in button
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            scale = min(scale + 0.5, 3.0)
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                            )
                    }
                    .disabled(scale >= 3.0)
                    .opacity(scale >= 3.0 ? 0.5 : 1.0)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
            .gesture(
                // Pinch to zoom
                MagnifyGesture()
                    .onChanged { value in
                        let delta = value.magnification / lastScale
                        lastScale = value.magnification
                        let newScale = scale * delta
                        // Limit zoom between 1x and 3x
                        scale = min(max(newScale, 1.0), 3.0)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                        // Clamp scale
                        scale = min(max(scale, 1.0), 3.0)
                    }
            )
            .simultaneousGesture(
                // Pan gesture
                DragGesture()
                    .onChanged { value in
                        if scale > 1.0 {
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .onTapGesture(count: 2) {
                // Double tap to reset zoom
                withAnimation(.spring(response: 0.3)) {
                    scale = 1.0
                    offset = .zero
                    lastOffset = .zero
                }
            }
            .clipped()
    }
}

// MARK: - City Marker Component

private struct CityMarker: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 2
                    )
                )
                .frame(width: 12, height: 12)
            
            // Main marker
            Circle()
                .fill(color)
                .frame(width: 4, height: 4)
                .shadow(color: color.opacity(0.5), radius: 1, y: 0.5)
        }
    }
}

// Extension to add normalized coordinates to CityAnnotation
extension CityAnnotation {
    // CALIBRATION SYSTEM - Use reference points to map coordinates
    // TODO: Adjust these reference points by visually checking where cities appear on your map image
    // For each city, find its visual position on your map (as percentage from left/top)
    
    // Reference points format: (latitude, longitude) -> (x%, y%) on your map image
    // You should measure where these cities actually appear on your "world-map" image
    private static let referencePoints: [(lat: Double, lon: Double, x: Double, y: Double)] = [
        // Example reference points - ADJUST THESE based on your actual map image:
        // London: roughly 51°N, 0°E - measure where it appears on your map
        (51.5074, -0.1278, 0.49, 0.32),  // Adjust x and y to match your map
        // Cairo: roughly 30°N, 31°E
        (30.0444, 31.2357, 0.54, 0.48),
        // Sydney: roughly -34°S, 151°E
        (-33.8688, 151.2093, 0.88, 0.75),
        // Los Angeles: roughly 34°N, -118°W
        (34.0522, -118.2437, 0.17, 0.47)
    ]
    
    // Calculate position using simple interpolation from reference points
    func normalizedX(in size: CGSize) -> Double {
        let longitude = coordinate.longitude
        
        // Simple linear mapping: longitude -180 to 180 maps to 0 to 1
        // Adjust these values if your map has different bounds
        let minLon: Double = -180
        let maxLon: Double = 180
        let mapLeft: Double = 0.02   // Where the map starts (left edge)
        let mapRight: Double = 0.98  // Where the map ends (right edge)
        
        let normalizedLon = (longitude - minLon) / (maxLon - minLon)
        return mapLeft + (normalizedLon * (mapRight - mapLeft))
    }
    
    func normalizedY(in size: CGSize) -> Double {
        let latitude = coordinate.latitude
        
        // For Mercator-style maps, use Web Mercator projection (EPSG:3857)
        // This is what Google Maps and most web maps use
        let minLat: Double = -85.0511  // Web Mercator limit
        let maxLat: Double = 85.0511
        let mapTop: Double = 0.08      // Where the map starts (top edge) - increased to push cities down
        let mapBottom: Double = 1.04   // Where the map ends (bottom edge) - increased to push cities down
        
        // Clamp latitude to Web Mercator bounds
        let clampedLat = min(max(latitude, minLat), maxLat)
        
        // Convert to Web Mercator Y
        let latRad = clampedLat * .pi / 180
        let mercatorY = log(tan(.pi / 4 + latRad / 2))
        
        // Normalize to 0-1 range (inverted because Y increases downward)
        let maxMercatorY = log(tan(.pi / 4 + maxLat * .pi / 180 / 2))
        let normalizedY = (maxMercatorY - mercatorY) / (2 * maxMercatorY)
        
        return mapTop + (normalizedY * (mapBottom - mapTop))
    }
}

// MARK: - Calibration Helper (for debugging)
extension CityAnnotation {
    // Use this to help calibrate your map
    // Print these values and visually check if cities are in the right position
    var calibrationInfo: String {
        """
        \(city.name):
          Coordinates: \(coordinate.latitude)°N, \(coordinate.longitude)°E
          Calculated position: x=\(String(format: "%.3f", normalizedX(in: .zero))), y=\(String(format: "%.3f", normalizedY(in: .zero)))
        """
    }
}

