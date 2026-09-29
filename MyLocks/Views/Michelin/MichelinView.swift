import SwiftUI
import SwiftData

struct MichelinView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @Query(sort: \MichelinRestaurant.createdAt, order: .reverse) 
    private var allRestaurants: [MichelinRestaurant]
    
    @State private var selectedTab: WishlistStatus? = nil // nil means "All"
    @State private var selectedFilter: MichelinFilter = .all
    @State private var selectedRestaurant: MichelinRestaurant?
    @State private var showingRestaurantDetail = false
    @State private var searchText = ""
    @State private var isSearching = false
    
    enum MichelinFilter: String, CaseIterable {
        case all = "All"
        case threeStars = "3 Stars"
        case twoStars = "2 Stars"
        case oneStar = "1 Star"
        case guide = "Guide"
        
        func matches(_ restaurant: MichelinRestaurant) -> Bool {
            switch self {
            case .all:
                return true
            case .threeStars:
                return restaurant.michelinLevel == 3
            case .twoStars:
                return restaurant.michelinLevel == 2
            case .oneStar:
                return restaurant.michelinLevel == 1
            case .guide:
                return restaurant.michelinLevel == 0
            }
        }
    }
    
    private var tabFilteredRestaurants: [MichelinRestaurant] {
        guard let tab = selectedTab else {
            // "All" tab selected - no specific sorting
            return allRestaurants
        }
        
        let filtered = allRestaurants.filter { $0.wishlistStatus == tab }
        
        // Sort based on status
        switch tab {
        case .visited:
            return MichelinRestaurant.sortedByRecentVisit(filtered)
        case .wishlisted:
            return MichelinRestaurant.sortedByWishlistPriority(filtered)
        case .notVisited:
            return filtered // Keep default order for not visited
        }
    }
    
    // REFACTORED: Using Searchable protocol extension
    private var filteredRestaurants: [MichelinRestaurant] {
        let baseFiltered = tabFilteredRestaurants.filter { selectedFilter.matches($0) }
        return baseFiltered.filtered(by: searchText, language: selectedLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // REFACTORED: Header with search functionality
                    HStack {
                        Button(action: {
                            if isSearching {
                                // Cancel search
                                isSearching = false
                                searchText = ""
                            }
                            // Plus button disabled when searching
                        }) {
                            Image(systemName: isSearching ? "xmark" : "plus")
                                .font(AppFonts.icon)
                                .foregroundStyle(AppColors.icon)
                        }
                        .disabled(isSearching && searchText.isEmpty)
                        
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
                        SearchBar(placeholder: "Search restaurants", text: $searchText)
                    }
                    
                    // Title
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(isSearching ? "Search Results" : "Michelin")
                            .font(AppFonts.title)
                            .foregroundStyle(AppColors.titleText)
                        
                        Text("\(filteredRestaurants.count) restaurant\(filteredRestaurants.count == 1 ? "" : "s")")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.secondaryText)
                    }
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
                    
                    // Star filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.pillInnerSpacing) {
                            ForEach(MichelinFilter.allCases, id: \.self) { filter in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedFilter = filter
                                    }
                                }) {
                                    Text(filter.rawValue)
                                        .font(AppFonts.callout)
                                        .filterButton(isSelected: selectedFilter == filter)
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.pageHorizontal)
                        .padding(.top, AppSpacing.md)
                    }
                    
                    // Restaurant list
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.cardSpacing) {
                            ForEach(filteredRestaurants) { restaurant in
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
                        .padding(.top, AppSpacing.sectionBottom)
                        .padding(.bottom, AppSpacing.contentBottom)
                        
                        // REFACTORED: Using EmptySearchState component
                        if filteredRestaurants.isEmpty && isSearching && !searchText.isEmpty {
                            EmptySearchState(itemType: "restaurants")
                        }
                    }
                }
                .navigationDestination(isPresented: $showingRestaurantDetail) {
                    if let restaurant = selectedRestaurant {
                        RestaurantDetailView(restaurant: restaurant)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isSearching)
            }
        }
    }
}

#Preview {
    MichelinView()
        .modelContainer(for: [MichelinRestaurant.self, RestaurantVisit.self, Country.self])
}
