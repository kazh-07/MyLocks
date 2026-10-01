import Foundation
import SwiftData

@Model
final class CountryVisit {
    @Attribute(.unique) var id: UUID
    var date: Date  // Stored date - used as fallback and for initial creation
    var notes: String?
    var country: Country?
    
    // Child city visits that are part of this country trip
    @Relationship(deleteRule: .cascade)
    var cityVisits: [CityVisit] = []
    
    init(country: Country? = nil, date: Date = Date(), notes: String? = nil, cityVisits: [CityVisit] = []) {
        self.id = UUID()
        self.country = country
        self.date = date
        self.notes = notes
        self.cityVisits = cityVisits
    }
    
    /// Returns the display date for this country visit
    /// Always uses the earliest city visit's start date when city visits exist
    /// Falls back to the stored date field only if no city visits exist
    var displayDate: Date? {
        if !cityVisits.isEmpty {
            // Find the earliest city visit start date
            let earliestDate = cityVisits.compactMap { $0.displayDate }.min()
            return earliestDate ?? date
        }
        return date
    }
    
    /// Returns the appropriate date precision for this country visit
    /// If all city visits use year precision, returns .year
    /// If any city visit uses exact precision, returns .exact
    /// If no city visits exist, defaults to .exact
    var effectiveDatePrecision: DatePrecision {
        guard !cityVisits.isEmpty else { return .exact }
        
        // If ANY city visit uses exact precision, use exact
        // This ensures we show the most precise information available
        if cityVisits.contains(where: { $0.datePrecision == .exact }) {
            return .exact
        }
        
        // All city visits use year precision
        return .year
    }
    
    /// Returns a formatted date string that respects the precision of city visits
    var formattedDateString: String {
        guard let displayDate = displayDate else { return "Unknown date" }
        
        switch effectiveDatePrecision {
        case .exact:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: displayDate)
            
        case .year:
            let calendar = Calendar.current
            let year = calendar.component(.year, from: displayDate)
            return String(year)
        }
    }
}
