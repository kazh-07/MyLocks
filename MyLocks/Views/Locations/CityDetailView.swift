import SwiftUI
import SwiftData

struct CityDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisible) private var tabBarVisible
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    let city: City
    
    @State private var showingAddVisit = false
    @State private var showingAddPlaces = false
    
    // MARK: - Delete Visit
    
    private func deleteVisit(_ visit: CityVisit) {
        withAnimation {
            // Get the parent country visit before deletion
            let parentCountryVisit = visit.parentCountryVisit
            
            // Check if this is the only city visit in the parent country visit
            // We check this BEFORE deleting the city visit
            let shouldDeleteParent = parentCountryVisit.cityVisits.count == 1
            
            // Delete the city visit
            modelContext.delete(visit)
            
            // If this was the only city visit, delete the parent country visit as well
            if shouldDeleteParent {
                modelContext.delete(parentCountryVisit)
            }
            
            // Save the context to persist the deletion
            do {
                try modelContext.save()
            } catch {
                print("Error deleting visit: \(error)")
            }
        }
    }
    
    // MARK: - Wishlist Toggle
    
    private func toggleWishlist() {
        if city.isWishlisted {
            // Remove wishlist (treating as boolean presence)
            if let wishlist = city.wishlists.first {
                modelContext.delete(wishlist)
            }
        } else {
            // Add a simple wishlist entry
            let wishlist = CityWishlist(
                city: city,
                note: nil,
                places: nil
            )
            modelContext.insert(wishlist)
            
            // Automatically wishlist the parent country if not already wishlisted or visited
            if let country = city.country, !country.isWishlisted && !country.isVisited {
                let countryWishlist = CountryWishlist(
                    country: country,
                    note: nil,
                    priority: nil
                )
                modelContext.insert(countryWishlist)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error toggling wishlist: \(error)")
        }
    }
    
    var body: some View {
        ZStack {
            // Background layer
            AppColors.background
                .ignoresSafeArea()
            
            // Content layer - respects safe area
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    // City title and info
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.md) {
                            Text(city.localizedName(language: selectedLanguage))
                                .font(AppFonts.title)
                                .foregroundStyle(AppColors.titleText)
                            
                            Spacer()
                            
                            // Show heart toggle ONLY for not-visited cities
                            if !city.isVisited {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        toggleWishlist()
                                    }
                                }) {
                                    Image(systemName: city.isWishlisted ? "heart.fill" : "heart")
                                        .font(AppFonts.icon)
                                        .foregroundStyle(city.isWishlisted ? AppColors.accent : AppColors.icon)
                                        .contentTransition(.symbolEffect(.replace))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if city.isVisited {
                                VisitedPill(visitCount: city.visits.count)
                            }
                        }
                        
                        // Show original name if viewing in Chinese and there's a Chinese name
                        if selectedLanguage == "Chinese", city.chineseName != nil {
                            Text(city.name)
                                .font(CityDetailStyles.header)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        
                        if let country = city.country {
                            Text(country.localizedName(language: selectedLanguage))
                                .font(CityDetailStyles.body)
                                .foregroundStyle(AppColors.tertiaryText)
                        }
                        
                        // Show tier and province for Chinese cities
                        if city.isChina {
                            HStack(spacing: AppSpacing.md) {
                                // City tier
                                if let tierText = city.localizedCityTier(language: selectedLanguage) {
                                    HStack(spacing: AppSpacing.xs) {
                                        Image(systemName: "building.2")
                                            .font(AppFonts.iconSmall)
                                            .foregroundStyle(AppColors.quaternaryText)
                                        
                                        Text(tierText)
                                            .font(CityDetailStyles.body)
                                            .foregroundStyle(AppColors.tertiaryText)
                                    }
                                }
                                
                                // Province
                                if let province = city.localizedProvince(language: selectedLanguage) {
                                    HStack(spacing: AppSpacing.xs) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(AppFonts.iconSmall)
                                            .foregroundStyle(AppColors.quaternaryText)
                                        
                                        Text(province)
                                            .font(CityDetailStyles.body)
                                            .foregroundStyle(AppColors.tertiaryText)
                                    }
                                }
                            }
                        }
                    }
                    
                    // City image - Wrapped in container to prevent layout issues - Wrapped in container to prevent layout issues
                    ZStack {
                        Color.clear
                        
                        if let thumbnailURL = city.thumbnailURL, let url = URL(string: thumbnailURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    RoundedRectangle(cornerRadius: AppDimensions.radiusLG)
                                        .fill(AppColors.cardBackground)
                                        .overlay(
                                            ProgressView()
                                                .tint(AppColors.iconLight)
                                        )
                                        .onAppear {
                                            print("🖼️ Loading image for \(city.name): \(url.absoluteString)")
                                        }
                                case .success(let image):
                                    GeometryReader { geometry in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .clipped()
                                    }
                                    .cornerRadius(AppDimensions.radiusLG)
                                    .onAppear {
                                        print("✅ Image loaded successfully for \(city.name)")
                                    }
                                case .failure(let error):
                                    RoundedRectangle(cornerRadius: AppDimensions.radiusLG)
                                        .fill(AppColors.cardBackground)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(AppFonts.iconLarge)
                                                .foregroundStyle(AppColors.iconLight)
                                        )
                                        .onAppear {
                                            print("❌ Failed to load image for \(city.name): \(error.localizedDescription)")
                                            print("   URL was: \(url.absoluteString)")
                                        }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            RoundedRectangle(cornerRadius: AppDimensions.radiusLG)
                                .fill(AppColors.cardBackground)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(AppFonts.iconLarge)
                                        .foregroundStyle(AppColors.iconLight)
                                )
                        }
                    }
                    .frame(height: CityDetailStyles.imageHeight)
                    .fixedSize(horizontal: false, vertical: true)
                    
                    // Visit records section
                    if !city.visits.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            let sortedVisits = city.visits.sorted { 
                                guard let date1 = $0.displayDate, let date2 = $1.displayDate else {
                                    return $0.displayDate != nil // Visits with dates come before those without
                                }
                                return date1 > date2
                            }
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
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        // Visited Places section - places from visits
                        if !city.visitedPlaces.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Visited Places")
                                    .font(RestaurantDetailStyles.sectionHeader)
                                    .foregroundStyle(AppColors.primaryText)
                                
                                // Horizontal scrolling places
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppSpacing.lg) {
                                        ForEach(city.visitedPlaces, id: \.self) { place in
                                            DishPill(dishName: place)
                                                .padding(.vertical, AppSpacing.lg)
                                        }
                                    }
                                    .padding(.horizontal, AppSpacing.md)
                                }
                            }
                        }
                        
                        // Wishlist Places section - places you want to visit
                        if city.isVisited || city.isWishlisted {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("Places to Visit")
                                        .font(RestaurantDetailStyles.sectionHeader)
                                        .foregroundStyle(AppColors.primaryText)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingAddPlaces = true
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(AppFonts.icon)
                                            .foregroundStyle(AppColors.accent)
                                    }
                                }
                                
                                if !city.wishlistPlaces.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: AppSpacing.lg) {
                                            ForEach(city.wishlistPlaces, id: \.self) { place in
                                                DishPill(dishName: place)
                                                    .padding(.vertical, AppSpacing.lg)
                                            }
                                        }
                                        .padding(.horizontal, AppSpacing.md)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
            AddCityVisitView(city: city)
        }
        .sheet(isPresented: $showingAddPlaces) {
            AddCityPlacesView(city: city)
        }
        .onAppear {
            tabBarVisible.wrappedValue = false
        }
        .onDisappear {
            tabBarVisible.wrappedValue = true
        }
    }
}
