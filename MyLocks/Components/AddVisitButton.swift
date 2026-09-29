import SwiftUI

/// A reusable button for adding a visit to cities or restaurants
struct AddVisitButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AddVisitButtonStyles.iconSpacing) {
                Image(systemName: "plus")
                    .font(AddVisitButtonStyles.iconFont)
                
                Text("Add a visit")
                    .font(AddVisitButtonStyles.textFont)
            }
            .foregroundStyle(AddVisitButtonStyles.textColor)
            .padding(.horizontal, AddVisitButtonStyles.horizontalPadding)
            .frame(height: AddVisitButtonStyles.height)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(AddVisitButtonStyles.background)
                    .shadow(
                        color: AddVisitButtonStyles.shadowColor,
                        radius: AddVisitButtonStyles.shadowRadius,
                        x: 0,
                        y: AddVisitButtonStyles.shadowY
                    )
            )
        }
    }
}

/// Extension with convenience initializer for custom text
extension AddVisitButton {
    init(text: String = "Add a visit", icon: String = "plus", action: @escaping () -> Void) {
        self.init(action: action)
    }
}

#Preview {
    VStack(spacing: 20) {
        AddVisitButton(action: {
            print("Add visit tapped")
        })
        .padding(.horizontal, AppSpacing.pageHorizontal)
        
        AddVisitButton(action: {})
            .padding(.horizontal, AppSpacing.pageHorizontal)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppColors.background)
}
