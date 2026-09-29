import SwiftUI
import SwiftData

/// A pill-shaped badge displaying city information
struct CityPill: View {
    let city: City
    var visited: Bool = true
    var onTap: (() -> Void)? = nil
    @State private var isPressed: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"

    var body: some View {
        HStack(spacing: AppSpacing.pillInnerSpacing) {
            // Country flag
            if let flag = city.country?.flagEmoji {
                Text(flag)
                    .font(AppFonts.emojiMedium)
            }

            // City name (localized)
            Text(city.localizedName(language: selectedLanguage))
                .font(AppFonts.callout)
                .foregroundStyle(visited ? AppColors.label : AppColors.secondaryText)
                .lineLimit(1)
            
            // Visit count badge
            if !city.visits.isEmpty {
                VisitCountBadge(visitCount: city.visits.count, isActive: visited)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .frame(height: AppDimensions.pillHeight)
        .background(
            Capsule()
                .fill(AppColors.cardBackground)
        )
        .overlay(
            Capsule()
                .strokeBorder(AppColors.tertiaryLabel, lineWidth: AppDimensions.pillBorderWidth)
        )
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed.toggle()
            }
            onTap?()
        }
    }
}

/// A grid of city pills with automatic wrapping
struct CityPillGrid: View {
    let cities: [City]
    var visited: Bool = true
    var onCityTap: ((City) -> Void)? = nil

    var body: some View {
        FlowLayout(spacing: AppSpacing.md) {
            ForEach(cities) { city in
                CityPill(city: city, visited: visited) {
                    onCityTap?(city)
                }
            }
        }
    }
}
