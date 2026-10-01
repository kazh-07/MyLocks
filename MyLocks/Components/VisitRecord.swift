import SwiftUI

/// Protocol that defines the common properties needed for visit display
protocol VisitDisplayable {
    var displayDate: Date? { get }
    var note: String? { get }
    var companion: String? { get }
}

/// Extend CityVisit to conform to VisitDisplayable
extension CityVisit: VisitDisplayable { }

/// Extend RestaurantVisit to conform to VisitDisplayable
/// RestaurantVisit has a 'date' property, so we map it to 'displayDate'
extension RestaurantVisit: VisitDisplayable {
    var displayDate: Date? { date }
}

/// Extend CountryVisit to conform to VisitDisplayable
extension CountryVisit: VisitDisplayable {
    var note: String? { notes }
    var companion: String? { nil }
}

/// A reusable component for displaying visit records with date and notes
/// Supports both city visits and restaurant visits
struct VisitRecord<T: VisitDisplayable>: View {
    let visit: T
    let visitIndex: Int // 1-based index (1st visit, 2nd visit, etc.)
    var isLast: Bool = false // Whether this is the last visit in the list
    var onDelete: (() -> Void)? = nil
    
    @State private var showDeleteConfirmation = false
    
    private var headerText: String {
        // If this is a CityVisit, format based on precision
        if let cityVisit = visit as? CityVisit {
            return cityVisit.formattedDateString
        }
        
        // Otherwise, format as a standard date
        guard let displayDate = visit.displayDate else {
            return "No date"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: displayDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header: Visit date
                HStack {
                    Text(headerText)
                        .font(CityDetailStyles.header)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    // City-specific: Show transportation method(s)
                    if let cityVisit = visit as? CityVisit,
                       let transportations = cityVisit.transportations,
                       !transportations.isEmpty {
                        HStack(spacing: AppSpacing.xs) {
                            ForEach(transportations, id: \.id) { transport in
                                Image(systemName: transport.mode.systemImage)
                                    .font(AppFonts.iconSmall)
                                    .foregroundStyle(AppColors.tertiaryText)
                            }
                        }
                    }
                    
                    // Restaurant-specific: Show rating
                    if let restaurantVisit = visit as? RestaurantVisit,
                       let rating = restaurantVisit.rating {
                        HStack(spacing: AppSpacing.xs) {
                            ForEach(0..<rating, id: \.self) { _ in
                                Image(systemName: "heart.fill")
                                    .font(AppFonts.iconSmall)
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }
                    
                    // Delete button (shown only when onDelete is provided)
                    if onDelete != nil {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .font(AppFonts.iconSmall)
                                .foregroundStyle(AppColors.quaternaryText)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Companion
                if let companion = visit.companion, !companion.isEmpty {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        Image(systemName: "person")
                            .font(AppFonts.iconMedium)
                            .foregroundStyle(AppColors.quaternaryText)
                        
                        Text(companion)
                            .font(CityDetailStyles.body)
                            .foregroundStyle(AppColors.quaternaryText)
                    }
                }
                
                // Body: Notes if available
                if let note = visit.note, !note.isEmpty {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        Image(systemName: "doc.text")
                            .font(CityDetailStyles.notesIcon)
                            .foregroundStyle(AppColors.icon)
                        
                        Text(note)
                            .font(CityDetailStyles.body)
                            .foregroundStyle(AppColors.tertiaryText)
                            .lineSpacing(4)
                    }
                }
            }
            
            // Divider - only show if not the last item
            if !isLast {
                Divider()
                    .background(AppColors.tertiaryLabel.opacity(0.3))
                    .padding(.vertical, AppSpacing.xl)
            }
        }
        .confirmationDialog(
            "Delete this visit?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

// MARK: - Preview

#Preview("Restaurant Visits") {
    VStack(spacing: AppSpacing.xl) {
        VisitRecord(
            visit: RestaurantVisit(
                date: Date(),
                companion: "Sarah Johnson",
                note: "Excellent meal, the atmosphere was perfect.",
                rating: 9
            ),
            visitIndex: 1
        )
        
        VisitRecord(
            visit: RestaurantVisit(
                date: Date().addingTimeInterval(-86400 * 60),
                companion: "Mark Chen",
                note: "Even better than last time!",
                rating: 10
            ),
            visitIndex: 2
        )
        
        VisitRecord(
            visit: RestaurantVisit(
                date: Date().addingTimeInterval(-86400 * 180),
                note: nil,
                rating: 8
            ),
            visitIndex: 3,
            isLast: true
        )
    }
    .padding()
    .background(AppColors.background)
}
