import Foundation
import SwiftData

@Model
final class CityVisit {
    @Attribute(.unique) var id: UUID
    
    // Date precision support (similar to Trip model)
    var datePrecision: DatePrecision
    var date: Date?              // For exact dates and month precision
    var approxYear: Int?         // For year precision
    var approxYearStart: Int?    // For year range precision
    var approxYearEnd: Int?      // For year range precision
    
    var companion: String?
    var note: String?
    var places: [String]?        // Notable places visited in the city
    var city: City?
    
    // Relationship to transportation records
    @Relationship(deleteRule: .cascade, inverse: \Transportation.cityVisit)
    var transportations: [Transportation]?

    init(date: Date, companion: String? = nil, note: String? = nil, places: [String]? = nil, city: City? = nil) {
        self.id = UUID()
        self.datePrecision = .exact
        self.date = date
        self.companion = companion
        self.note = note
        self.places = places
        self.city = city
    }
    
    init(
        datePrecision: DatePrecision,
        date: Date? = nil,
        approxYear: Int? = nil,
        approxYearStart: Int? = nil,
        approxYearEnd: Int? = nil,
        companion: String? = nil,
        note: String? = nil,
        places: [String]? = nil,
        city: City? = nil
    ) {
        self.id = UUID()
        self.datePrecision = datePrecision
        self.date = date
        self.approxYear = approxYear
        self.approxYearStart = approxYearStart
        self.approxYearEnd = approxYearEnd
        self.companion = companion
        self.note = note
        self.places = places
        self.city = city
    }
    
    /// Returns the most recent displayable date available
    var displayDate: Date? {
        var candidates: [Date] = []
        
        // Add exact/month date if available
        if let date = date {
            candidates.append(date)
        }
        
        // Add approximate year if available
        if let year = approxYear {
            var components = DateComponents()
            components.year = year
            components.month = 1
            components.day = 1
            if let yearDate = Calendar.current.date(from: components) {
                candidates.append(yearDate)
            }
        }
        
        // Add year range start if available
        if let yearStart = approxYearStart {
            var components = DateComponents()
            components.year = yearStart
            components.month = 1
            components.day = 1
            if let rangeDate = Calendar.current.date(from: components) {
                candidates.append(rangeDate)
            }
        }
        
        // Return the most recent date, or nil if none available
        return candidates.max()
    }
    
    /// Returns a formatted string based on date precision
    var formattedDateString: String {
        switch datePrecision {
        case .exact:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date ?? Date())
            
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date ?? Date())
            
        case .year:
            if let year = approxYear {
                return String(year)
            }
            return "Unknown year"
            
        case .yearRange:
            if let start = approxYearStart, let end = approxYearEnd {
                return "\(start)–\(end)"
            }
            return "Unknown range"
        }
    }
}
