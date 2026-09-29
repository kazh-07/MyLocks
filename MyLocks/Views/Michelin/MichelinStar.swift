import SwiftUI

/// A view that displays Michelin star rating or "Guide" label for restaurants
struct MichelinStar: View {
    let michelinLevel: Int
    var size: Size = .small
    
    enum Size {
        case small
        case large
    }
    
    private var starCount: Int {
        max(0, min(3, michelinLevel))
    }
    
    var body: some View {
        if michelinLevel == 0 {
            // Michelin Guide (no stars)
            Text("Guide")
                .font(size == .small ? MichelinStarStyles.smallLabelFont : MichelinStarStyles.largeLabelFont)
                .foregroundStyle(AppColors.quaternaryText)
        } else {
            // Star rating (1-3 stars) - show only the earned stars
            HStack(spacing: size == .small ? MichelinStarStyles.smallSpacing : MichelinStarStyles.largeSpacing) {
                ForEach(0..<starCount, id: \.self) { _ in
                    Image("michelin-star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: size == .small ? MichelinStarStyles.smallStarSize : MichelinStarStyles.largeStarSize,
                            height: size == .small ? MichelinStarStyles.smallStarSize : MichelinStarStyles.largeStarSize
                        )
                }
            }
        }
    }
}

#Preview("Michelin Star Ratings") {
    VStack(alignment: .leading, spacing: AppSpacing.xl) {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Small Size")
                .font(AppFonts.headline)
            
            HStack(spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Guide")
                    MichelinStar(michelinLevel: 0, size: .small)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("1 Star")
                    MichelinStar(michelinLevel: 1, size: .small)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("2 Stars")
                    MichelinStar(michelinLevel: 2, size: .small)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("3 Stars")
                    MichelinStar(michelinLevel: 3, size: .small)
                }
            }
        }
        
        Divider()
        
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Large Size")
                .font(AppFonts.headline)
            
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Guide")
                    MichelinStar(michelinLevel: 0, size: .large)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("1 Star")
                    MichelinStar(michelinLevel: 1, size: .large)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("2 Stars")
                    MichelinStar(michelinLevel: 2, size: .large)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("3 Stars")
                    MichelinStar(michelinLevel: 3, size: .large)
                }
            }
        }
    }
    .padding()
    .background(AppColors.background)
}
