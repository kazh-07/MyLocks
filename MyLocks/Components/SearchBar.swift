import SwiftUI

struct SearchBar: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(AppFonts.icon)
                .foregroundStyle(AppColors.secondaryText)
            
            TextField(placeholder, text: $text)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.primaryText)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, AppSpacing.pageHorizontal)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppDimensions.radiusMD)
        .padding(.horizontal, AppSpacing.pageHorizontal)
        .padding(.top, AppSpacing.sm)
    }
}
