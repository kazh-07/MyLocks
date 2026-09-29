import SwiftUI

/// A small capsule badge for displaying visit count
struct VisitCountBadge: View {
    let visitCount: Int
    var isActive: Bool = true
    
    var body: some View {
        Text("\(visitCount)")
            .font(AppFonts.badge)
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.pillInnerSpacing)
            .padding(.vertical, AppSpacing.pillVertical)
            .background(
                Capsule()
                    .fill(isActive ? AppColors.label.opacity(0.7) : AppColors.secondaryText.opacity(0.7))
            )
    }
}

/// A pill-shaped badge indicating visited status
struct VisitedPill: View {
    var visitCount: Int = 1
    
    var body: some View {
        HStack(spacing: VisitPillStyles.innerSpacing) {
            Text("\(visitCount)")
                .font(VisitPillStyles.countFont)
                .foregroundStyle(VisitPillStyles.countColor)
            
            Text(visitCount > 1 ? "times" : "time")
                .font(VisitPillStyles.labelFont)
                .foregroundStyle(VisitPillStyles.labelColor)
        }
        .padding(.horizontal, VisitPillStyles.horizontalPadding)
        .frame(height: VisitPillStyles.height)
        .background(
            Capsule()
                .fill(VisitPillStyles.background)
                .shadow(
                    color: VisitPillStyles.shadowColor,
                    radius: VisitPillStyles.shadowRadius,
                    x: 0,
                    y: VisitPillStyles.shadowY
                )
        )
    }
}

#Preview("Badges") {
    VStack(spacing: AppSpacing.lg) {
        HStack(spacing: AppSpacing.md) {
            VisitCountBadge(visitCount: 1)
            VisitCountBadge(visitCount: 5)
            VisitCountBadge(visitCount: 12)
        }
        
        HStack(spacing: AppSpacing.md) {
            VisitCountBadge(visitCount: 3, isActive: false)
        }
        
        VisitedPill(visitCount: 1)
        VisitedPill(visitCount: 3)
    }
    .padding()
    .background(AppColors.background)
}

