import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \City.name) private var allCities: [City]
    @Query(sort: \MichelinRestaurant.createdAt, order: .reverse) private var allRestaurants: [MichelinRestaurant]
    @State private var selectedTab = "Cities"
    @State private var selectedCity: City?
    @State private var selectedRestaurant: MichelinRestaurant?
    @State private var showingCityDetail = false
    @State private var showingRestaurantDetail = false
    @State private var showingSettings = false
    @State private var searchText = ""
    @State private var isSearching = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    // REFACTORED: Using Searchable protocol extension
    private var visitedCities: [City] {
        let visited = allCities.filter { $0.isVisited }
        // Sort by most recent visit
        let sorted = City.sortedByRecentVisit(visited)
        guard isSearching && selectedTab == "Cities" else { return sorted }
        return sorted.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var wishlistedCities: [City] {
        let wishlisted = allCities.filter { $0.wishlistStatus == .wishlisted }
        // Sort by priority, then by date added
        let sorted = City.sortedByWishlistPriority(wishlisted)
        guard isSearching && selectedTab == "Cities" else { return sorted }
        return sorted.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var visitedRestaurants: [MichelinRestaurant] {
        let visited = allRestaurants.filter { $0.isVisited }
        // Sort by most recent visit
        let sorted = MichelinRestaurant.sortedByRecentVisit(visited)
        guard isSearching && selectedTab == "Michelin" else { return sorted }
        return sorted.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var wishlistedRestaurants: [MichelinRestaurant] {
        let wishlisted = allRestaurants.filter { $0.wishlistStatus == .wishlisted }
        // Sort by priority, then by date added
        let sorted = MichelinRestaurant.sortedByWishlistPriority(wishlisted)
        guard isSearching && selectedTab == "Michelin" else { return sorted }
        return sorted.filtered(by: searchText, language: selectedLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Content
                    ScrollView {
                        Group {
                            switch selectedTab {
                            case "Cities":
                                citiesContent
                            case "Michelin":
                                michelinContent
                            default:
                                placeholderContent
                            }
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            // REFACTORED: Header with settings and search buttons
                            HStack {
                                // Settings button or cancel button when searching
                                Button(action: {
                                    if isSearching {
                                        isSearching = false
                                        searchText = ""
                                    } else {
                                        showingSettings = true
                                    }
                                }) {
                                    Image(systemName: isSearching ? "xmark" : "gearshape")
                                        .font(AppFonts.icon)
                                        .foregroundStyle(AppColors.icon)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    isSearching.toggle()
                                    if !isSearching {
                                        searchText = ""
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .font(AppFonts.icon)
                                        .foregroundStyle(AppColors.icon)
                                }
                            }
                            .padding(.horizontal, AppSpacing.pageHorizontal)
                            .padding(.vertical, AppSpacing.pageTop)
                            
                            // REFACTORED: Using SearchBar component
                            if isSearching {
                                SearchBar(
                                    placeholder: selectedTab == "Cities" ? "Search cities" : "Search restaurants",
                                    text: $searchText
                                )
                            }
                            
                            // Title
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("My Locks")
                                    .font(AppFonts.title)
                                    .foregroundStyle(AppColors.titleText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.pageHorizontal)
                            .padding(.top, AppSpacing.sectionTop)
                            .padding(.bottom, AppSpacing.sectionBottom)
                            
                            // Custom tab bar with refined styling
                            TabBar(
                                tabs: [
                                    ("Cities", "Cities"),
                                    ("Michelin", "Michelin"),
                                    ("Events", "Events"),
                                    ("Others", "Others")
                                ],
                                selectedTab: $selectedTab
                            )
                        }
                        .background(AppColors.background)
                    }
                }
                .navigationDestination(isPresented: $showingCityDetail) {
                    if let city = selectedCity {
                        CityDetailView(city: city)
                    }
                }
                .navigationDestination(isPresented: $showingRestaurantDetail) {
                    if let restaurant = selectedRestaurant {
                        RestaurantDetailView(restaurant: restaurant)
                    }
                }
                .navigationDestination(isPresented: $showingSettings) {
                    SettingsView()
                }
                .animation(.easeInOut(duration: 0.2), value: isSearching)
            }
        }
    }
    
    // MARK: - Cities Content
    
    @ViewBuilder
    private var citiesContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxl) {
            // Stats header with refined typography
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("\(visitedCities.count)")
                        .font(AppFonts.display)
                        .foregroundStyle(AppColors.label)
                        .tracking(-1)
                    
                    Text("cities")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.secondaryLabel)
                }
                
                Spacer()
                
                Image(systemName: "globe")
                    .font(AppFonts.iconExtraLarge)
                    .foregroundStyle(AppColors.quaternaryLabel)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.horizontal, AppSpacing.pageHorizontal)
            .padding(.top, AppSpacing.xxl)
            
            // Visited section with refined typography
            if !visitedCities.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Text("Visited")
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.label)
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                    
                    CityPillGrid(cities: visitedCities, visited: true) { city in
                        selectedCity = city
                        showingCityDetail = true
                    }
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                }
            }
            
            // Wishlisted section with refined typography
            if !wishlistedCities.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Text("Wishlisted")
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.label)
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                    
                    CityPillGrid(cities: wishlistedCities, visited: false) { city in
                        selectedCity = city
                        showingCityDetail = true
                    }
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                }
            }
            
            Spacer(minLength: AppSpacing.paddingBottom)
        }
    }
    
    // MARK: - Michelin Content
    
    @ViewBuilder
    private var michelinContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxl) {
            // Stats header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("\(visitedRestaurants.count)")
                        .font(AppFonts.display)
                        .foregroundStyle(AppColors.label)
                        .tracking(-1)
                    
                    Text("restaurant\(visitedRestaurants.count == 1 ? "" : "s")")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.secondaryLabel)
                }
                
                Spacer()
                
                Image("michelin-star")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 48)
                    .foregroundStyle(AppColors.quaternaryLabel)
            }
            .padding(.horizontal, AppSpacing.pageHorizontal)
            .padding(.top, AppSpacing.xxl)
            
            // Visited section
            if !visitedRestaurants.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Text("Visited")
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.label)
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                    
                    LazyVStack(spacing: AppSpacing.cardSpacing) {
                        ForEach(visitedRestaurants) { restaurant in
                            Button(action: {
                                selectedRestaurant = restaurant
                                showingRestaurantDetail = true
                            }) {
                                RestaurantRow(restaurant: restaurant)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                }
            }
            
            // Wishlisted section
            if !wishlistedRestaurants.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Text("Wishlisted")
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.label)
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                    
                    LazyVStack(spacing: AppSpacing.cardSpacing) {
                        ForEach(wishlistedRestaurants) { restaurant in
                            Button(action: {
                                selectedRestaurant = restaurant
                                showingRestaurantDetail = true
                            }) {
                                RestaurantRow(restaurant: restaurant)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                }
            }
            
            Spacer(minLength: AppSpacing.paddingBottom)
        }
    }
    
    // MARK: - Placeholder Content
    
    @ViewBuilder
    private var placeholderContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxl) {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                Text("Coming Soon")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.secondaryLabel)
                
                Text("This section is under development")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.tertiaryLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, AppSpacing.xxl)
            
            Spacer(minLength: AppSpacing.paddingBottom)
        }
    }
}
