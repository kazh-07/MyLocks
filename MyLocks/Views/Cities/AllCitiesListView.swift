import SwiftUI
import SwiftData

struct AllCitiesListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisible) private var tabBarVisible
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    let cities: [City]
    
    @State private var selectedCity: City?
    @State private var showingCityDetail = false
    @State private var selectedTab: WishlistStatus? = nil // nil means "All"
    @State private var searchText = ""
    @State private var isSearching = false
    
    private var tabFilteredCities: [City] {
        guard let tab = selectedTab else {
            // "All" tab selected - no specific sorting
            return cities
        }
        
        let filtered = cities.filter { $0.wishlistStatus == tab }
        
        // Sort based on status
        switch tab {
        case .visited:
            return City.sortedByRecentVisit(filtered)
        case .wishlisted:
            return City.sortedByWishlistPriority(filtered)
        case .notVisited:
            return filtered // Keep default order for not visited
        }
    }
    
    // REFACTORED: Using Searchable protocol extension
    private var searchFilteredCities: [City] {
        tabFilteredCities.filtered(by: searchText, language: selectedLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // REFACTORED: Header with search functionality
                    HStack {
                        Button(action: {
                            if isSearching {
                                // Cancel search
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
                    
                    // REFACTORED: Using SearchBar component
                    if isSearching {
                        SearchBar(placeholder: "Search cities", text: $searchText)
                    }
                
                    // Title
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(isSearching ? "Search Results" : "All Cities")
                            .font(AppFonts.title)
                            .foregroundStyle(AppColors.titleText)
                        
                        Text("\(searchFilteredCities.count) cit\(searchFilteredCities.count == 1 ? "y" : "ies")")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.secondaryText)
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
                        
                        // REFACTORED: Using EmptySearchState component
                        if searchFilteredCities.isEmpty && isSearching && !searchText.isEmpty {
                            EmptySearchState(itemType: "cities")
                        }
                    }
                }
                .navigationBarHidden(true)
                .navigationDestination(isPresented: $showingCityDetail) {
                    if let city = selectedCity {
                        CityDetailView(city: city)
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
