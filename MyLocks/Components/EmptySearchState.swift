import SwiftUI

struct EmptySearchState: View {
    let itemType: String
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.secondaryText.opacity(0.5))
            
            VStack(spacing: AppSpacing.sm) {
                Text("No \(itemType) found")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Try adjusting your search")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xl)
    }
}
