import SwiftUI

/// Protocol that defines the common properties needed for visit display
protocol VisitDisplayable {
    var displayDate: Date? { get }
    var note: String? { get }
    var companion: String? { get }
    var rating: Int? { get }
}

/// Extend CityVisit to conform to VisitDisplayable
/// CityVisit doesn't have rating, so we provide nil default
extension CityVisit: VisitDisplayable {
    var rating: Int? { nil }
}

/// Extend RestaurantVisit to conform to VisitDisplayable
/// RestaurantVisit has a 'date' property, so we map it to 'displayDate'
extension RestaurantVisit: VisitDisplayable {
    var displayDate: Date? { date }
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
    
    private var visitNumberText: String {
        switch visitIndex {
        case 1: return "1st visit"
        case 2: return "2nd visit"
        case 3: return "3rd visit"
        default: return "\(visitIndex)th visit"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header: Visit date or visit number
                HStack {
                    Text(headerText)
                        .font(CityDetailStyles.header)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    // Show visit number as secondary info
                    Text(visitNumberText)
                        .font(CityDetailStyles.body)
                        .foregroundStyle(AppColors.tertiaryText)
                    
                    // Delete button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .font(AppFonts.iconSmall)
                            .foregroundStyle(AppColors.quaternaryText)
                    }
                    .buttonStyle(.plain)
                }
                
                // Restaurant-specific: Rating
                if let rating = visit.rating {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        Image(systemName: "star.fill")
                            .font(AppFonts.iconMedium)
                            .foregroundStyle(AppColors.quaternaryText)
                        
                        Text("\(rating)")
                            .font(CityDetailStyles.body)
                            .foregroundStyle(AppColors.quaternaryText)
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
            .padding(.vertical, AppSpacing.xl)
            
            // Divider - only show if not the last item
            if !isLast {
                Divider()
                    .background(AppColors.tertiaryLabel.opacity(0.3))
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

#Preview("City Visits") {
    VStack(spacing: AppSpacing.xl) {
        VisitRecord(
            visit: CityVisit(
                date: Date(),
                note: "This was an amazing trip! The food was incredible and the weather was perfect."
            ),
            visitIndex: 1
        )
        
        VisitRecord(
            visit: CityVisit(
                date: Date().addingTimeInterval(-86400 * 30),
                note: nil
            ),
            visitIndex: 2
        )
        
        VisitRecord(
            visit: CityVisit(
                date: Date().addingTimeInterval(-86400 * 365),
                note: "Second trip here, even better than the first!"
            ),
            visitIndex: 3,
            isLast: true
        )
    }
    .padding()
    .background(AppColors.background)
}

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
