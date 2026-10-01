import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \City.name) private var allCities: [City]
    @Query(sort: \Country.name) private var allCountries: [Country]
    @Query(sort: \MichelinRestaurant.createdAt, order: .reverse) private var allRestaurants: [MichelinRestaurant]
    @State private var selectedTab = "Locations"
    @State private var locationViewMode: LocationViewMode = .cities
    @State private var selectedCity: City?
    @State private var selectedCountry: Country?
    @State private var selectedRestaurant: MichelinRestaurant?
    @State private var showingCityDetail = false
    @State private var showingCountryDetail = false
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
        guard isSearching && selectedTab == "Locations" else { return sorted }
        return sorted.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var wishlistedCities: [City] {
        let wishlisted = allCities.filter { $0.wishlistStatus == .wishlisted }
        // Sort by priority, then by date added
        let sorted = City.sortedByWishlistPriority(wishlisted)
        guard isSearching && selectedTab == "Locations" else { return sorted }
        return sorted.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var visitedCountries: [Country] {
        let visited = allCountries.filter { $0.isVisited }
        // Sort by most recent visit
        let sorted = Country.sortedByRecentVisit(visited)
        guard isSearching && selectedTab == "Locations" else { return sorted }
        return sorted.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var wishlistedCountries: [Country] {
        let wishlisted = allCountries.filter { $0.wishlistStatus == .wishlisted }
        // Sort by priority, then by date added
        let sorted = Country.sortedByWishlistPriority(wishlisted)
        guard isSearching && selectedTab == "Locations" else { return sorted }
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
                            case "Locations":
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
                                    placeholder: selectedTab == "Locations" ? 
                                        (locationViewMode == .cities ? "Search cities" : "Search countries") : 
                                        "Search restaurants",
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
                                    ("Locations", "Locations"),
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
                .navigationDestination(isPresented: $showingCountryDetail) {
                    if let country = selectedCountry {
                        CountryDetailView(country: country)
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
            // Stats header with inline menu on the label
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("\(locationViewMode == .cities ? visitedCities.count : visitedCountries.count)")
                        .font(AppFonts.display)
                        .foregroundStyle(AppColors.label)
                        .tracking(-1)
                    
                    // Replaced Picker(.menu) with Menu to avoid system tinting of the label.
                    Menu {
                        Button {
                            locationViewMode = .cities
                        } label: {
                            HStack {
                                if locationViewMode == .cities {
                                    Image(systemName: "checkmark")
                                }
                                Text("Cities")
                            }
                        }
                        Button {
                            locationViewMode = .countries
                        } label: {
                            HStack {
                                if locationViewMode == .countries {
                                    Image(systemName: "checkmark")
                                }
                                Text("Countries")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(locationViewMode == .cities ? "cities" : "countries")
                                .font(AppFonts.body)
                                .foregroundStyle(AppColors.secondaryLabel)
                            Image(systemName: "chevron.down")
                                .font(AppFonts.iconSmall)
                                .foregroundStyle(AppColors.tertiaryLabel)
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 4)
                    }
                    .menuStyle(.automatic)
                }
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.pageHorizontal)
            .padding(.top, AppSpacing.xxl)
            
            // Content based on mode
            if locationViewMode == .cities {
                // Visited cities section
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
                
                // Wishlisted cities section
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
            } else {
                // Visited countries section
                if !visitedCountries.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        Text("Visited")
                            .font(AppFonts.headline)
                            .foregroundStyle(AppColors.label)
                            .padding(.horizontal, AppSpacing.pageHorizontal)
                        
                        CountryPillGrid(countries: visitedCountries, visited: true) { country in
                            selectedCountry = country
                            showingCountryDetail = true
                        }
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                    }
                }
                
                // Wishlisted countries section
                if !wishlistedCountries.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        Text("Wishlisted")
                            .font(AppFonts.headline)
                            .foregroundStyle(AppColors.label)
                            .padding(.horizontal, AppSpacing.pageHorizontal)
                        
                        CountryPillGrid(countries: wishlistedCountries, visited: false) { country in
                            selectedCountry = country
                            showingCountryDetail = true
                        }
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                    }
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
