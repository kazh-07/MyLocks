import SwiftUI

// MARK: - App Colors

enum AppColors {
    // Backgrounds
    static let background = Color.white
    static let cardBackground = Color(red: 0.984, green: 0.98, blue: 0.988)
    
    // Text colors (custom)
    static let titleText = Color(red: 0.15, green: 0.15, blue: 0.2)
    static let primaryText = Color(red: 0.2, green: 0.23, blue: 0.3)
    static let secondaryText = Color(red: 0.55, green: 0.55, blue: 0.58)
    static let tertiaryText = Color(red: 0.55, green: 0.57, blue: 0.62)
    static let quaternaryText = Color(red: 0.65, green: 0.67, blue: 0.72)
    
    // System colors (auto dark mode)
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)
    static let separator = Color(UIColor.separator)
    
    // Semantic colors
    static let icon = Color(red: 0.4, green: 0.4, blue: 0.45)
    static let iconLight = Color(red: 0.7, green: 0.7, blue: 0.72)
    static let accent = Color(red: 0.3, green: 0.65, blue: 0.5) // Teal - used for markers, highlights
    static let emptyState = Color(red: 0.75, green: 0.77, blue: 0.8) // Light gray for empty states
    static let selected = Color.white
    static let selectedBackground = Color(red: 0.15, green: 0.18, blue: 0.25)
    static let visitedIndicator = Color(red: 0.3, green: 0.65, blue: 0.5) // Teal - matches accent color
}

// MARK: - App Fonts

enum AppFonts {
    // Semantic font scale
    static let display = Font.system(size: 72, weight: .light, design: .serif)
    static let title = Font.system(size: 36, weight: .regular, design: .serif)
    static let headline = Font.system(size: 22, weight: .semibold, design: .serif)
    static let subheadline = Font.system(size: 18, weight: .semibold, design: .serif)
    static let body = Font.system(size: 16, weight: .regular)
    static let bodyEmphasis = Font.system(size: 16, weight: .semibold, design: .serif)
    static let callout = Font.system(size: 15, weight: .medium)
    static let caption = Font.system(size: 14, weight: .regular)
    static let footnote = Font.system(size: 12, weight: .regular)
    static let badge = Font.system(size: 11, weight: .semibold)
    
    // List item fonts
    static let itemTitle = Font.system(size: 17, weight: .semibold, design: .serif)
    static let itemSubtitle = Font.system(size: 14, weight: .regular)
    static let itemCaption = Font.system(size: 12, weight: .regular)
    
    // Icon sizes
    static let icon = Font.system(size: 20)
    static let iconSmall = Font.system(size: 11)
    static let iconMedium = Font.system(size: 16)
    static let iconLarge = Font.system(size: 24)
    static let iconXL = Font.system(size: 52, weight: .ultraLight)
    static let iconExtraLarge = Font.system(size: 48, weight: .ultraLight)
    
    // Emoji sizes
    static let emojiMedium = Font.system(size: 16)
}

// MARK: - App Spacing

enum AppSpacing {
    // Base spacing scale (use these for consistency)
    static let xs: CGFloat = 2
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    
    // Page layout
    static let pageHorizontal: CGFloat = xxl  // 24
    static let pageTop: CGFloat = md          // 8
    static let sectionTop: CGFloat = xl
    static let sectionBottom: CGFloat = 20
    static let sectionSpacing: CGFloat = xxxl // 32
    static let contentBottom: CGFloat = 100
    
    // Padding
    static let paddingSmall: CGFloat = md     // 8
    static let paddingMedium: CGFloat = xl    // 16
    static let paddingLarge: CGFloat = xxl    // 24
    static let paddingBottom: CGFloat = 80    // Bottom padding for scrollable content
    
    // Component spacing
    static let cardSpacing: CGFloat = xl      // 16
    static let cardPadding: CGFloat = xl
    static let buttonSpacing: CGFloat = lg    // 12
    static let buttonHorizontal: CGFloat = 20
    static let buttonVertical: CGFloat = 10
    static let pillInnerSpacing: CGFloat = 6
    static let pillVertical: CGFloat = 3
    static let pillHorizontalPadding = lg
    static let pillGridSpacing = md
    static let flowLayoutDefaultSpacing: CGFloat = 10
}

// MARK: - App Dimensions

enum AppDimensions {
    // Size scale
    static let sizeXS: CGFloat = 8
    static let sizeSM: CGFloat = 12
    static let sizeMD: CGFloat = 20
    static let sizeLG: CGFloat = 36
    static let sizeXL: CGFloat = 50
    
    // Corner radius scale
    static let radiusSM: CGFloat = 12
    static let radiusMD: CGFloat = 16
    static let radiusLG: CGFloat = 20
    static let radiusXL: CGFloat = 24
    
    // Common dimensions
    static let iconSize: CGFloat = sizeMD        // 20
    static let buttonHeight: CGFloat = sizeXL     // 50
    static let thumbnailSize: CGFloat = 80
    
    // Opacity scale
    static let opacitySubtle: CGFloat = 0.04
    static let opacityLight: CGFloat = 0.1
    static let opacityMedium: CGFloat = 0.3
    static let opacityStrong: CGFloat = 0.5
    
    // Shadows
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 2
    static let shadowRadiusLarge: CGFloat = 12
    
    // Thumbnail Dimensions
    static let thumbnailSmall: CGFloat = 60
    static let thumbnailMedium = thumbnailSize  // 80
    static let thumbnailLarge: CGFloat = 100
    
    // Component dimensions
    static let pillHeight = sizeLG  // 36
    static let pillBorderWidth: CGFloat = 1.5
    static let borderWidth: CGFloat = 0.5
}

// MARK: - Component Styles

enum MichelinStyles {
    static let imageSize = AppDimensions.thumbnailMedium
    static let imageCornerRadius = AppDimensions.radiusLG
    static let cardCornerRadius = AppDimensions.radiusLG
    static let cardHeight: CGFloat = 112
    
    // Spacing
    static let titleSpacing = AppSpacing.sm
    static let cardInnerSpacing = AppSpacing.xl
    static let cardContentSpacing = AppSpacing.sm
    static let starSpacing = AppSpacing.sm
    static let heartSpacing: CGFloat = 6
    static let rightColumnSpacing = AppSpacing.md
    static let ratingTopPadding = AppSpacing.xs
}

enum MichelinStarStyles {
    // Small style (for RestaurantRow)
    static let smallStarSize: CGFloat = 16
    static let smallSpacing = AppSpacing.sm
    static let smallLabelFont = AppFonts.caption
    
    // Large style (for RestaurantDetailView)
    static let largeStarSize = AppDimensions.iconSize
    static let largeSpacing = AppSpacing.sm
    static let largeLabelFont = Font.system(size: 15, weight: .regular)
}

enum CityDetailStyles {
    // Fonts
    static let header = Font.system(size: 18, weight: .semibold, design: .serif)
    static let body = Font.system(size: 15, weight: .regular)
    static let notesIcon = Font.system(size: 16)
    static let addButtonText = Font.system(size: 16, weight: .semibold)
    static let addButtonIcon = Font.system(size: 16, weight: .semibold)
    
    // Dimensions
    static let imageHeight: CGFloat = 280
    
    // Spacing
    static let titleSpacing = AppSpacing.md
    static let imageBottom = AppSpacing.paddingLarge
    static let visitSection = AppSpacing.xl
    static let visitDateSpacing = AppSpacing.paddingLarge
    static let visitSectionBottom = AppSpacing.paddingLarge
    static let notesIconSpacing = AppSpacing.md
    static let notesSpacing = AppSpacing.lg
    static let notesBottom = AppSpacing.xxxl
    static let addButtonSpacing = AppSpacing.md
    static let addButtonBottom: CGFloat = 40
}

enum RestaurantDetailStyles {
    // Fonts
    static let restaurantName = Font.system(size: 36, weight: .regular, design: .serif)
    static let locationText = Font.system(size: 15, weight: .regular)
    static let ratingNumber = Font.system(size: 18, weight: .semibold)
    static let reviewsText = Font.system(size: 15, weight: .regular)
    static let sectionHeader = Font.system(size: 18, weight: .semibold, design: .serif)
    static let dateText = Font.system(size: 17, weight: .regular)
    static let notesText = Font.system(size: 15, weight: .regular)
    static let starIcon = Font.system(size: 16)
    static let dateIcon = Font.system(size: 22)
    static let notesIcon = Font.system(size: 22)
    
    // Dimensions
    static let imageHeight: CGFloat = 240
    static let imageCornerRadius = AppDimensions.radiusXL
    static let ratingCircleSize: CGFloat = 56
    
    // Colors
    static let visitedBackground = Color(red: 0.9, green: 0.96, blue: 0.92)
    static let visitedText = Color(red: 0.3, green: 0.7, blue: 0.45)
}

enum HomeStyles {
    // Spacing
    static let statsTop = AppSpacing.xxl
    static let statsInnerSpacing = AppSpacing.xs
    static let sectionInnerSpacing = AppSpacing.xl
    static let sectionSpacing = AppSpacing.xxxl
    static let tabBarTop = AppSpacing.md
}

enum MapStyles {
    // Dimensions
    static let maxHeight: CGFloat = 500
    static let aspectRatio: CGFloat = 0.8
    static let markerInnerSize: CGFloat = 4
    static let markerGlowRadius: CGFloat = 2
    static let markerShadowRadius: CGFloat = 1
    static let markerShadowY: CGFloat = 0.5
    static let fallbackPadding: CGFloat = 40
    static let imageOpacity: CGFloat = 0.4
    
    // Spacing
    static let horizontalPadding: CGFloat = 20
    static let topPadding = AppSpacing.xl
    static let zoomButtonSpacing = AppSpacing.lg
}

enum TabBarStyles {
    // Fonts
    static let icon = Font.system(size: 20)
    static let addIcon = Font.system(size: 20, weight: .semibold)
    static let label = Font.system(size: 10, weight: .medium)
    
    // Dimensions
    static let underlineHeight: CGFloat = 2.5
    static let dividerHeight: CGFloat = 0.5
    static let dividerOpacity: CGFloat = 0.06
    
    // Spacing
    static let buttonUnderlineSpacing = AppSpacing.md
    static let buttonHorizontal = AppSpacing.md
    static let buttonMinWidth: CGFloat = 60
    static let horizontal = AppSpacing.md
    static let top = AppSpacing.md
    static let bottom: CGFloat = 7
    static let itemSpacing = AppSpacing.sm
}

enum DishPillStyles {
    // Font
    static let dishName = Font.system(size: 14, weight: .regular)
    
    // Dimensions
    static let dishPillHeight = AppDimensions.pillHeight
    static let dishPillCornerRadius: CGFloat = 15
    static let dishPillShadowRadius: CGFloat = 6
    static let dishPillShadowY: CGFloat = 2.2
    
    // Colors
    static let dishPillBackground = Color.white
    static let dishPillText = Color(red: 0.45, green: 0.47, blue: 0.52)
    static let dishPillShadow = Color.black.opacity(0.08)
}

enum AddVisitStyles {
    // Row insets for form sections
    static let rowInsets = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
    
    // Line limits
    static let notesLineLimit = 3...6
    static let dishesLineLimit = 2...4
}

enum VisitPillStyles {
    // Fonts
    static let countFont = AppFonts.callout
    static let labelFont = AppFonts.callout
    
    // Colors
    static let background = AppColors.background
    static let countColor = AppColors.label
    static let labelColor = AppColors.secondaryLabel
    static let shadowColor = Color.black.opacity(0.08)
    
    // Dimensions
    static let height = AppDimensions.pillHeight
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 2
    
    // Spacing
    static let horizontalPadding = AppSpacing.lg
    static let innerSpacing = AppSpacing.pillInnerSpacing
}

enum AddVisitButtonStyles {
    // Fonts
    static let textFont = Font.system(size: 16, weight: .medium)
    static let iconFont = Font.system(size: 16, weight: .medium)
    
    // Colors
    static let background = AppColors.background
    static let textColor = AppColors.label
    static let shadowColor = Color.black.opacity(0.08)
    
    // Dimensions
    static let height: CGFloat = 44 // Slightly taller than pill (36)
    static let cornerRadius: CGFloat = 22 // Half of height for capsule effect
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 2
    
    // Spacing
    static let horizontalPadding = AppSpacing.xl
    static let iconSpacing = AppSpacing.md
}

// MARK: - View Modifiers
struct FilterButtonStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .font(AppFonts.callout)
            .foregroundStyle(isSelected ? AppColors.selected : AppColors.secondaryText)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.pillInnerSpacing)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.selectedBackground : AppColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(AppDimensions.opacitySubtle),
                        radius: AppDimensions.shadowRadius,
                        x: 0,
                        y: AppDimensions.shadowY
                    )
            )
    }
}

extension View {
    func filterButton(isSelected: Bool) -> some View {
        modifier(FilterButtonStyle(isSelected: isSelected))
    }
    
    /// Applies serif font styling to navigation bar titles
    func serifNavigationBar() -> some View {
        self.onAppear {
            let largeTitleFont = UIFont(descriptor: 
                UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
                    .withDesign(.serif)?
                    .withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle),
                size: 34)
            
            let titleFont = UIFont(descriptor:
                UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
                    .withDesign(.serif)?
                    .withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline),
                size: 17)
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.largeTitleTextAttributes = [.font: largeTitleFont, .foregroundColor: UIColor.label]
            appearance.titleTextAttributes = [.font: titleFont, .foregroundColor: UIColor.label]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }
    }
}
