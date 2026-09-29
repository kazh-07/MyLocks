import SwiftUI
import SwiftData

struct RestaurantDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisible) private var tabBarVisible
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @Bindable var restaurant: MichelinRestaurant
    
    @State private var showingAddVisit = false
    
    // MARK: - Delete Visit
    
    private func deleteVisit(_ visit: RestaurantVisit) {
        withAnimation {
            modelContext.delete(visit)
            
            // Save the context to persist the deletion
            do {
                try modelContext.save()
            } catch {
                print("Error deleting visit: \(error)")
            }
        }
    }
    
    private var visitDates: [Date] {
        restaurant.visits.compactMap(\.date).sorted()
    }
    
    private var combinedNotes: String {
        restaurant.visits
            .compactMap { $0.note }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    private var mostRecentVisitRating: Int? {
        // Get the most recent visit with a rating
        restaurant.visits
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
            .first { $0.rating != nil }?
            .rating
    }
    
    private var allSignatureDishes: [String] {
        // Collect all unique signature dishes from all visits and wishlists
        var dishes = Set<String>()
        
        // Add dishes from visits
        restaurant.visits.forEach { visit in
            if let visitDishes = visit.signatureDishes {
                visitDishes.forEach { dishes.insert($0) }
            }
        }
        
        // Add dishes from wishlists
        restaurant.wishlists.forEach { wishlist in
            if let wishlistDishes = wishlist.signatureDishes {
                wishlistDishes.forEach { dishes.insert($0) }
            }
        }
        
        return Array(dishes).sorted()
    }
    
    var body: some View {
        ZStack {
            // Background layer
            AppColors.background
                .ignoresSafeArea()
            
            // Content layer - respects safe area
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    // Restaurant image
                    if let thumbnailURL = restaurant.thumbnailURL, let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: RestaurantDetailStyles.imageCornerRadius)
                                    .fill(AppColors.cardBackground)
                                    .frame(height: RestaurantDetailStyles.imageHeight)
                                    .overlay(
                                        ProgressView()
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: RestaurantDetailStyles.imageHeight)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: RestaurantDetailStyles.imageCornerRadius))
                            case .failure:
                                RoundedRectangle(cornerRadius: RestaurantDetailStyles.imageCornerRadius)
                                    .fill(AppColors.cardBackground)
                                    .frame(height: RestaurantDetailStyles.imageHeight)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(AppFonts.iconExtraLarge)
                                            .foregroundStyle(AppColors.iconLight)
                                    )
                            @unknown default:
                                RoundedRectangle(cornerRadius: RestaurantDetailStyles.imageCornerRadius)
                                    .fill(AppColors.cardBackground)
                                    .frame(height: RestaurantDetailStyles.imageHeight)
                            }
                        }
                        .padding(.bottom, AppSpacing.lg)
                    } else {
                        // Placeholder when no thumbnail URL is available
                        RoundedRectangle(cornerRadius: RestaurantDetailStyles.imageCornerRadius)
                            .fill(AppColors.cardBackground)
                            .frame(height: RestaurantDetailStyles.imageHeight)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(AppFonts.iconExtraLarge)
                                    .foregroundStyle(AppColors.iconLight)
                            )
                            .padding(.bottom, AppSpacing.lg)
                    }
                    
                    // Restaurant name and visit rating
                    HStack(alignment: .top) {
                        Text(restaurant.localizedName(language: selectedLanguage))
                            .font(RestaurantDetailStyles.restaurantName)
                            .foregroundStyle(AppColors.titleText)
                        
                        Spacer()
                        
                        // Visit rating number
                        if let rating = mostRecentVisitRating {
                            Text("\(rating)")
                                .font(RestaurantDetailStyles.restaurantName)
                                .foregroundStyle(AppColors.titleText)
                        }
                    }
                    
                    // Location
                    if let city = restaurant.city, let country = restaurant.country {
                        Text("\(city.localizedName(language: selectedLanguage)), \(country.localizedName(language: selectedLanguage))")
                            .font(RestaurantDetailStyles.locationText)
                            .foregroundStyle(AppColors.quaternaryText)
                    }
                    
                    // Cuisine type
                    if let cuisine = restaurant.localizedCuisine(language: selectedLanguage) {
                        Text(cuisine)
                            .font(RestaurantDetailStyles.locationText)
                            .foregroundStyle(AppColors.quaternaryText)
                    }
                    
                    // Michelin stars
                    MichelinStar(michelinLevel: restaurant.michelinLevel, size: .large)
                    
                    // Visit record section
                    if !visitDates.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            let sortedVisits = restaurant.visits.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
                            ForEach(Array(sortedVisits.enumerated()), id: \.element.id) { index, visit in
                                VisitRecord(
                                    visit: visit,
                                    visitIndex: sortedVisits.count - index, // Reverse index: newest visit = highest number
                                    isLast: index == sortedVisits.count - 1,
                                    onDelete: {
                                        deleteVisit(visit)
                                    }
                                )
                            }
                        }
                        
                        // Divider between visit records and signature dishes
                        Divider()
                            .background(AppColors.tertiaryLabel.opacity(0.3))
                            .padding(.bottom, AppSpacing.xl)
                    }
                    
                    // Signature dishes section
                    if !allSignatureDishes.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Signature Dishes")
                                .font(RestaurantDetailStyles.sectionHeader)
                                .foregroundStyle(AppColors.primaryText)
                            
                            // Horizontal scrolling dishes
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.lg) {
                                    ForEach(allSignatureDishes, id: \.self) { dish in
                                        DishPill(dishName: dish)
                                            .padding(.vertical, AppSpacing.lg)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.md)
                            }
                        }
                        .padding(.bottom, AppSpacing.lg)
                    }
                }
                .padding(.bottom, AppSpacing.contentBottom)
                .padding(.horizontal, AppSpacing.pageHorizontal)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                DetailHeader(trailingButtonStyle: .add) {
                    showingAddVisit = true
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddVisit) {
            AddRestaurantVisitView(restaurant: restaurant)
        }
        .onAppear {
            tabBarVisible.wrappedValue = false
        }
        .onDisappear {
            tabBarVisible.wrappedValue = true
        }
    }
}
