import SwiftUI

/// A reusable tab button with underline indicator
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TabBarStyles.buttonUnderlineSpacing) {
                Text(title)
                    .font(isSelected ? AppFonts.callout.weight(.semibold) : AppFonts.callout.weight(.regular))
                    .foregroundStyle(isSelected ? AppColors.label : AppColors.tertiaryLabel)
                
                // Underline indicator
                Rectangle()
                    .fill(isSelected ? AppColors.label : Color.clear)
                    .frame(height: TabBarStyles.underlineHeight)
            }
            .frame(minWidth: TabBarStyles.buttonMinWidth)
            .padding(.horizontal, TabBarStyles.buttonHorizontal)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TabBar Component

/// A reusable tab bar component with divider
struct TabBar<T: Equatable>: View {
    let tabs: [(title: String, value: T)]
    @Binding var selectedTab: T
    var showDivider: Bool = true
    var dividerBottomPadding: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    let tab = tabs[index]
                    TabButton(title: tab.title, isSelected: selectedTab == tab.value) {
                        selectedTab = tab.value
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.pageHorizontal)
            .padding(.top, AppSpacing.md)
            
            if showDivider {
                Divider()
                    .opacity(AppDimensions.opacityMedium)
                    .padding(.bottom, dividerBottomPadding)
            }
        }
    }
}

// MARK: - Optional TabBar Component

/// A tab bar that supports optional selection (where nil can represent "All")
struct OptionalTabBar<T: Equatable>: View {
    let tabs: [(title: String, value: T?)]
    @Binding var selectedTab: T?
    var showDivider: Bool = true
    var dividerBottomPadding: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    let tab = tabs[index]
                    TabButton(title: tab.title, isSelected: isSelected(tab.value)) {
                        selectedTab = tab.value
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.pageHorizontal)
            .padding(.top, AppSpacing.md)
            
            if showDivider {
                Divider()
                    .opacity(AppDimensions.opacityMedium)
                    .padding(.bottom, dividerBottomPadding)
            }
        }
    }
    
    private func isSelected(_ value: T?) -> Bool {
        if let value = value, let selected = selectedTab {
            return value == selected
        } else if value == nil && selectedTab == nil {
            return true
        }
        return false
    }
}
