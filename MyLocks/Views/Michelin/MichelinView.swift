import SwiftUI
import SwiftData

struct MichelinView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MichelinRestaurant.createdAt, order: .reverse) 
    private var allRestaurants: [MichelinRestaurant]
    
    @State private var selectedTab: WishlistStatus? = nil // nil means "All"
    @State private var selectedFilter: MichelinFilter = .all
    @State private var selectedRestaurant: MichelinRestaurant?
    @State private var showingRestaurantDetail = false
    
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
            // "All" tab selected
            return allRestaurants
        }
        
        return allRestaurants.filter { $0.wishlistStatus == tab }
    }
    
    private var filteredRestaurants: [MichelinRestaurant] {
        tabFilteredRestaurants.filter { selectedFilter.matches($0) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(AppFonts.icon)
                                .foregroundStyle(AppColors.icon)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(AppFonts.icon)
                                .foregroundStyle(AppColors.icon)
                        }
                    }
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                    .padding(.top, AppSpacing.pageTop)
                    
                    // Title
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Michelin")
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
                    }
                }
                .navigationDestination(isPresented: $showingRestaurantDetail) {
                    if let restaurant = selectedRestaurant {
                        RestaurantDetailView(restaurant: restaurant)
                    }
                }
            }
        }
    }
}

#Preview {
    MichelinView()
        .modelContainer(for: [MichelinRestaurant.self, RestaurantVisit.self, Country.self])
}
