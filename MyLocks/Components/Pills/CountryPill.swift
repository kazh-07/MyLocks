import SwiftUI
import SwiftData

/// A pill-shaped badge displaying country information
struct CountryPill: View {
    let country: Country
    var visited: Bool = true
    var onTap: (() -> Void)? = nil
    @State private var isPressed: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"

    var body: some View {
        HStack(spacing: AppSpacing.pillInnerSpacing) {
            // Country flag
            if let flag = country.flagEmoji {
                Text(flag)
                    .font(AppFonts.emojiMedium)
            }

            // Country name (localized)
            Text(country.localizedName(language: selectedLanguage))
                .font(AppFonts.callout)
                .foregroundStyle(visited ? AppColors.label : AppColors.secondaryText)
                .lineLimit(1)
            
            // Visit count badge
            if !country.visits.isEmpty {
                VisitCountBadge(visitCount: country.visits.count, isActive: visited)
            }
            
            // City count indicator (for countries)
            if !country.cities.filter({ $0.isVisited }).isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "building.2.fill")
                        .font(AppFonts.iconSmall)
                    Text("\(country.cities.filter { $0.isVisited }.count)")
                        .font(AppFonts.badge)
                }
                .foregroundStyle(visited ? AppColors.secondaryLabel : AppColors.tertiaryText)
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

/// A grid of country pills with automatic wrapping
struct CountryPillGrid: View {
    let countries: [Country]
    var visited: Bool = true
    var onCountryTap: ((Country) -> Void)? = nil

    var body: some View {
        FlowLayout(spacing: AppSpacing.md) {
            ForEach(countries) { country in
                CountryPill(country: country, visited: visited) {
                    onCountryTap?(country)
                }
            }
        }
    }
}
