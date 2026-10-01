import SwiftUI
import SwiftData

struct AllLocationsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisible) private var tabBarVisible
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    let cities: [City]
    @Query(sort: \Country.name) private var allCountries: [Country]
    
    @State private var selectedCity: City?
    @State private var showingCityDetail = false
    @State private var selectedCountry: Country?
    @State private var showingCountryDetail = false
    @State private var locationViewMode: LocationViewMode = .cities
    @State private var selectedTab: WishlistStatus? = nil
    @State private var searchText = ""
    @State private var isSearching = false
    
    // MARK: - Filtering and Search
    
    private var tabFilteredCities: [City] {
        guard let tab = selectedTab else {
            return cities
        }
        
        let filtered = cities.filter { $0.wishlistStatus == tab }
        
        switch tab {
        case .visited:
            return City.sortedByRecentVisit(filtered)
        case .wishlisted:
            return City.sortedByWishlistPriority(filtered)
        case .notVisited:
            return filtered
        }
    }
    
    private var tabFilteredCountries: [Country] {
        guard let tab = selectedTab else {
            return allCountries
        }
        
        let filtered = allCountries.filter { $0.wishlistStatus == tab }
        
        switch tab {
        case .visited:
            return Country.sortedByRecentVisit(filtered)
        case .wishlisted:
            return Country.sortedByWishlistPriority(filtered)
        case .notVisited:
            return filtered
        }
    }
    
    private var searchFilteredCities: [City] {
        tabFilteredCities.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var searchFilteredCountries: [Country] {
        tabFilteredCountries.filtered(by: searchText, language: selectedLanguage)
    }
    
    private var currentCount: Int {
        locationViewMode == .cities ? searchFilteredCities.count : searchFilteredCountries.count
    }
    
    private var itemTypeLabel: String {
        switch locationViewMode {
        case .cities:
            return currentCount == 1 ? "city" : "cities"
        case .countries:
            return currentCount == 1 ? "country" : "countries"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with back button and search
                    HStack {
                        Button(action: {
                            if isSearching {
                                isSearching = false
                                searchText = ""
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: isSearching ? "xmark" : "chevron.left")
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
                    
                    // Search bar
                    if isSearching {
                        SearchBar(
                            placeholder: locationViewMode == .cities ? "Search cities" : "Search countries",
                            text: $searchText
                        )
                    }
                    
                    // Title + inline mode menu in the count line
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(isSearching ? "Search Results" : (locationViewMode == .cities ? "All Cities" : "All Countries"))
                            .font(AppFonts.title)
                            .foregroundStyle(AppColors.titleText)
                        
                        HStack(spacing: 4) {
                            Text("\(currentCount)")
                                .font(AppFonts.body)
                                .foregroundStyle(AppColors.secondaryText)
                            
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
                                    Text(itemTypeLabel)
                                        .font(AppFonts.body)
                                        .foregroundStyle(AppColors.secondaryText)
                                    Image(systemName: "chevron.down")
                                        .font(AppFonts.iconSmall)
                                        .foregroundStyle(AppColors.tertiaryLabel)
                                }
                                .contentShape(Rectangle())
                                .padding(.vertical, 2)
                            }
                            .menuStyle(.automatic)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                    .padding(.top, AppSpacing.sectionTop)
                    .padding(.bottom, AppSpacing.sectionBottom)
                    
                    // Status tab bar
                    OptionalTabBar(
                        tabs: [
                            ("Visited", .visited),
                            ("Wishlist", .wishlisted),
                            ("Not Yet", .notVisited),
                            ("All", nil)
                        ],
                        selectedTab: $selectedTab,
                        dividerBottomPadding: AppSpacing.md
                    )
                    
                    // Content
                    ScrollView {
                        if locationViewMode == .cities {
                            FlowLayout(spacing: AppSpacing.md) {
                                ForEach(searchFilteredCities) { city in
                                    CityPill(city: city, visited: city.isVisited) {
                                        selectedCity = city
                                        showingCityDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.pageHorizontal)
                            .padding(.top, AppSpacing.md)
                            .padding(.bottom, AppSpacing.contentBottom)
                            
                            if searchFilteredCities.isEmpty && isSearching && !searchText.isEmpty {
                                EmptySearchState(itemType: "cities")
                            }
                        } else {
                            FlowLayout(spacing: AppSpacing.md) {
                                ForEach(searchFilteredCountries) { country in
                                    CountryPill(country: country, visited: country.isVisited) {
                                        selectedCountry = country
                                        showingCountryDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.pageHorizontal)
                            .padding(.top, AppSpacing.md)
                            .padding(.bottom, AppSpacing.contentBottom)
                            
                            if searchFilteredCountries.isEmpty && isSearching && !searchText.isEmpty {
                                EmptySearchState(itemType: "countries")
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
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
                .onAppear {
                    tabBarVisible.wrappedValue = false
                }
                .animation(.easeInOut(duration: 0.2), value: isSearching)
            }
        }
    }
}
