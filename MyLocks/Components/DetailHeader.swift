import SwiftUI

/// A reusable header view for detail screens with back button and optional action button
struct DetailHeader: View {
    @Environment(\.dismiss) private var dismiss
    
    enum TrailingButtonStyle {
        case menu
        case add
    }
    
    let trailingButtonStyle: TrailingButtonStyle
    let onTrailingButtonTap: () -> Void
    
    init(trailingButtonStyle: TrailingButtonStyle = .menu, onTrailingButtonTap: @escaping () -> Void = {}) {
        self.trailingButtonStyle = trailingButtonStyle
        self.onTrailingButtonTap = onTrailingButtonTap
    }
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(AppFonts.icon)
                    .foregroundStyle(AppColors.icon)
            }
            
            Spacer()
            
            Button(action: onTrailingButtonTap) {
                Image(systemName: trailingButtonStyle == .menu ? "ellipsis" : "plus")
                    .font(AppFonts.icon)
                    .foregroundStyle(AppColors.icon)
            }
        }
        .padding(.horizontal, AppSpacing.pageHorizontal)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.sectionBottom)
        .background(AppColors.background)
    }
}

#Preview {
    VStack {
        DetailHeader()
        Spacer()
    }
    .background(AppColors.background)
}
