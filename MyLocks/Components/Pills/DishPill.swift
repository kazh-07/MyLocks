import SwiftUI

/// A pill-shaped component displaying a dish name with elevated shadow effect
struct DishPill: View {
    let dishName: String
    
    var body: some View {
        Text(dishName)
            .font(DishPillStyles.dishName)
            .foregroundStyle(DishPillStyles.dishPillText)
            .padding(.horizontal, AppSpacing.xl)
            .frame(height: DishPillStyles.dishPillHeight)
            .background(DishPillStyles.dishPillBackground)
            .clipShape(RoundedRectangle(cornerRadius: DishPillStyles.dishPillCornerRadius))
            .shadow(
                color: DishPillStyles.dishPillShadow,
                radius: DishPillStyles.dishPillShadowRadius,
                x: 0,
                y: DishPillStyles.dishPillShadowY
            )
    }
}

#Preview {
    VStack(spacing: AppSpacing.xl) {
        DishPill(dishName: "Seafood platter")
        DishPill(dishName: "Tuna tartare")
        DishPill(dishName: "Lobster")
    }
    .padding()
    .background(AppColors.background)
}
