import SwiftUI
import SwiftData

struct CountryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    let country: Country
    
    @State private var showingAddVisit = false
    @State private var selectedCity: City?
    @State private var showingCityDetail = false
    
    // MARK: - Delete Visit
    
    private func deleteCountryVisit(_ visit: CountryVisit) {
        withAnimation {
            modelContext.delete(visit)
            do {
                try modelContext.save()
            } catch {
                print("Error deleting visit: \(error)")
            }
        }
    }
    
    // MARK: - Wishlist Toggle
    
    private func toggleWishlist() {
        if country.isWishlisted {
            // Remove wishlist
            if let wishlist = country.wishlists.first {
                modelContext.delete(wishlist)
            }
            
            // CASCADE: Remove all city wishlists for cities in this country
            for city in country.cities {
                if city.isWishlisted {
                    for cityWishlist in city.wishlists {
                        modelContext.delete(cityWishlist)
                    }
                }
            }
        } else {
            // Add a simple wishlist entry
            let wishlist = CountryWishlist(
                country: country,
                note: nil,
                priority: nil
            )
            modelContext.insert(wishlist)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error toggling wishlist: \(error)")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background layer
            AppColors.background
                .ignoresSafeArea()
            
            // Content layer - respects safe area
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    // Country title and info
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            if let flag = country.flagEmoji {
                                Text(flag)
                                    .font(.system(size: 32))
                            }
                            
                            Text(country.localizedName(language: selectedLanguage))
                                .font(AppFonts.title)
                                .foregroundStyle(AppColors.titleText)
                            
                            Spacer()
                            
                            // Show heart toggle ONLY for not-visited countries
                            if !country.isVisited {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        toggleWishlist()
                                    }
                                }) {
                                    Image(systemName: country.isWishlisted ? "heart.fill" : "heart")
                                        .font(AppFonts.icon)
                                        .foregroundStyle(country.isWishlisted ? AppColors.accent : AppColors.icon)
                                        .contentTransition(.symbolEffect(.replace))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if country.isVisited {
                                // Count only country-level visits (not individual city visits)
                                VisitedPill(visitCount: country.visits.count)
                            }
                        }
                        
                        // Country info
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            if let continent = country.continent {
                                Text(continent)
                                    .font(AppFonts.body)
                                    .foregroundStyle(AppColors.secondaryLabel)
                            }
                            
                            Text("\(country.code)")
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.tertiaryLabel)
                        }
                    }
                    .padding(.horizontal, AppSpacing.pageHorizontal)
                    .padding(.top, AppSpacing.pageTop)
                    
                    // Cities in this country
                    if !country.cities.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.xl) {
                            Text("Cities")
                                .font(AppFonts.headline)
                                .foregroundStyle(AppColors.label)
                                .padding(.horizontal, AppSpacing.pageHorizontal)
                            
                            let visitedCities = country.cities.filter { $0.isVisited }
                            let wishlistedCities = country.cities.filter { $0.wishlistStatus == .wishlisted }
                            
                            if !visitedCities.isEmpty {
                                VStack(alignment: .leading, spacing: AppSpacing.md) {
                                    Text("Visited (\(visitedCities.count))")
                                        .font(AppFonts.callout)
                                        .foregroundStyle(AppColors.secondaryLabel)
                                        .padding(.horizontal, AppSpacing.pageHorizontal)
                                    
                                    CityPillGrid(cities: visitedCities, visited: true) { city in
                                        selectedCity = city
                                        showingCityDetail = true
                                    }
                                    .padding(.horizontal, AppSpacing.pageHorizontal)
                                }
                            }
                            
                            if !wishlistedCities.isEmpty {
                                VStack(alignment: .leading, spacing: AppSpacing.md) {
                                    Text("Wishlisted (\(wishlistedCities.count))")
                                        .font(AppFonts.callout)
                                        .foregroundStyle(AppColors.secondaryLabel)
                                        .padding(.horizontal, AppSpacing.pageHorizontal)
                                    
                                    CityPillGrid(cities: wishlistedCities, visited: false) { city in
                                        selectedCity = city
                                        showingCityDetail = true
                                    }
                                    .padding(.horizontal, AppSpacing.pageHorizontal)
                                }
                            }
                        }
                    }
                    
                    // Visits section - shows country visits with their city visits nested
                    if !country.visits.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.xl) {
                            HStack {
                                Text("Visits")
                                    .font(AppFonts.headline)
                                    .foregroundStyle(AppColors.label)
                                
                                Spacer()
                                
                                Text("\(country.visits.count)")
                                    .font(AppFonts.headline)
                                    .foregroundStyle(AppColors.secondaryLabel)
                            }
                            .padding(.horizontal, AppSpacing.pageHorizontal)
                            
                            VStack(spacing: AppSpacing.md) {
                                ForEach(country.visits.sorted(by: { ($0.displayDate ?? .distantPast) > ($1.displayDate ?? .distantPast) })) { visit in
                                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                        HStack {
                                            // Date - shows earliest city visit date if available, respecting precision
                                            Text(visit.formattedDateString)
                                                .font(AppFonts.callout)
                                                .foregroundStyle(AppColors.label)
                                            
                                            Spacer()
                                            
                                            // Show city count if this visit has city visits
                                            if !visit.cityVisits.isEmpty {
                                                Text("\(visit.cityVisits.count) \(visit.cityVisits.count == 1 ? "city" : "cities")")
                                                    .font(AppFonts.caption)
                                                    .foregroundStyle(AppColors.secondaryLabel)
                                            } else {
                                                Text("Country visit")
                                                    .font(AppFonts.caption)
                                                    .foregroundStyle(AppColors.secondaryLabel)
                                            }
                                            
                                            // Delete button
                                            Button(role: .destructive) {
                                                deleteCountryVisit(visit)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(AppFonts.iconSmall)
                                                    .foregroundStyle(AppColors.tertiaryLabel)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        // Show notes if available
                                        if let notes = visit.notes, !notes.isEmpty {
                                            Text(notes)
                                                .font(AppFonts.caption)
                                                .foregroundStyle(AppColors.secondaryLabel)
                                                .lineLimit(2)
                                        }
                                        
                                        // Show city visits under this country visit
                                        if !visit.cityVisits.isEmpty {
                                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                                ForEach(visit.cityVisits.sorted(by: { ($0.displayDate ?? .distantPast) < ($1.displayDate ?? .distantPast) })) { cityVisit in
                                                    HStack(spacing: AppSpacing.xs) {
                                                        Image(systemName: "arrow.turn.down.right")
                                                            .font(.caption2)
                                                            .foregroundStyle(AppColors.tertiaryLabel)
                                                        
                                                        if let city = cityVisit.city {
                                                            Text(city.localizedName(language: selectedLanguage))
                                                                .font(AppFonts.caption)
                                                                .foregroundStyle(AppColors.secondaryLabel)
                                                        }
                                                        
                                                        Text("•")
                                                            .font(AppFonts.caption)
                                                            .foregroundStyle(AppColors.tertiaryLabel)
                                                        
                                                        Text(cityVisit.formattedDateString)
                                                            .font(AppFonts.caption)
                                                            .foregroundStyle(AppColors.tertiaryLabel)
                                                    }
                                                }
                                            }
                                            .padding(.leading, AppSpacing.md)
                                            .padding(.top, AppSpacing.xs)
                                        }
                                    }
                                    .padding(.horizontal, AppSpacing.pageHorizontal)
                                    .padding(.vertical, AppSpacing.sm)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: AppSpacing.paddingBottom)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingCityDetail) {
            if let city = selectedCity {
                CityDetailView(city: city)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingAddVisit = true
                }) {
                    Image(systemName: "plus")
                        .font(AppFonts.icon)
                        .foregroundStyle(AppColors.icon)
                }
            }
        }
        .sheet(isPresented: $showingAddVisit) {
            AddCountryVisitView(country: country)
        }
    }
}
