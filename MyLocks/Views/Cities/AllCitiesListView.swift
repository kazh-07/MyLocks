import SwiftUI
import SwiftData

struct AllCitiesListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisible) private var tabBarVisible
    let cities: [City]
    
    @State private var selectedCity: City?
    @State private var showingCityDetail = false
    
    private var visitedCities: [City] {
        cities.filter { $0.isVisited }
    }
    
    private var wishlistedCities: [City] {
        cities.filter { $0.wishlistStatus == .wishlisted }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
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
                    Text("All Cities")
                        .font(AppFonts.title)
                        .foregroundStyle(AppColors.titleText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.pageHorizontal)
                .padding(.top, AppSpacing.sectionTop)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xxxl) {
                        // Stats header
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
                        
                        // Visited section
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
                        
                        // Wishlisted section
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
        }
    }
}
}
