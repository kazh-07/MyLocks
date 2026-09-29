import SwiftUI
import SwiftData

/// A card displaying restaurant information with ratings and visit tracking
struct RestaurantRow: View {
    let restaurant: MichelinRestaurant
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    var body: some View {
        HStack(spacing: AppSpacing.xl) {
            // Restaurant image
            if let thumbnailURL = restaurant.thumbnailURL, let url = URL(string: thumbnailURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: MichelinStyles.imageCornerRadius)
                            .fill(AppColors.cardBackground)
                            .frame(width: MichelinStyles.imageSize, height: MichelinStyles.imageSize)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.7)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: MichelinStyles.imageSize, height: MichelinStyles.imageSize)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: MichelinStyles.imageCornerRadius))
                    case .failure:
                        RoundedRectangle(cornerRadius: MichelinStyles.imageCornerRadius)
                            .fill(AppColors.cardBackground)
                            .frame(width: MichelinStyles.imageSize, height: MichelinStyles.imageSize)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(AppFonts.iconLarge)
                                    .foregroundStyle(AppColors.iconLight)
                            )
                    @unknown default:
                        RoundedRectangle(cornerRadius: MichelinStyles.imageCornerRadius)
                            .fill(AppColors.cardBackground)
                            .frame(width: MichelinStyles.imageSize, height: MichelinStyles.imageSize)
                    }
                }
            } else {
                // Placeholder when no thumbnail URL is available
                RoundedRectangle(cornerRadius: MichelinStyles.imageCornerRadius)
                    .fill(AppColors.cardBackground)
                    .frame(width: MichelinStyles.imageSize, height: MichelinStyles.imageSize)
                    .overlay(
                        Image(systemName: "photo")
                            .font(AppFonts.iconLarge)
                            .foregroundStyle(AppColors.iconLight)
                    )
            }
            
            // Restaurant info
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Title and rating row
                HStack(alignment: .firstTextBaseline) {
                    Text(restaurant.localizedName(language: selectedLanguage))
                        .font(AppFonts.itemTitle)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    // Numeric rating
                    if let rating = restaurant.rating {
                        Text(String(format: "%.1f", rating))
                            .font(AppFonts.itemTitle)
                            .foregroundStyle(AppColors.primaryText)
                    }
                }
                
                if let city = restaurant.city, let country = restaurant.country {
                    let countryDisplay = selectedLanguage == "Chinese" 
                        ? country.localizedName(language: selectedLanguage)
                        : country.code
                    Text("\(city.localizedName(language: selectedLanguage)), \(countryDisplay)")
                        .font(AppFonts.itemSubtitle)
                        .foregroundStyle(AppColors.tertiaryText)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
                
                // Michelin star and last visit row
                HStack {
                    MichelinStar(michelinLevel: restaurant.michelinLevel, size: .small)
                    
                    Spacer()
                    
                    if let lastVisit = restaurant.lastVisitDate {
                        Text(lastVisit, format: .dateTime.year().month(.twoDigits).day(.twoDigits))
                            .font(AppFonts.itemCaption)
                            .foregroundStyle(AppColors.quaternaryText)
                    }
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: MichelinStyles.cardCornerRadius)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        )
    }
}
