import Foundation
import SwiftData

@Model
final class CityVisit {
    @Attribute(.unique) var id: UUID
    
    // Date precision support - ALL precisions now support ranges
    var datePrecision: DatePrecision
    
    // For exact date and month precision
    var startDate: Date?         // Start of the visit
    var endDate: Date?           // End of the visit (can be same as startDate for single-day visits)
    
    // For year precision
    var startYear: Int?          // Start year
    var endYear: Int?            // End year (can be same as startYear for single-year visits)
    
    var companion: String?
    var note: String?
    var places: [String]?        // Notable places visited in the city
    var city: City?
    
    // Relationship to transportation records
    @Relationship(deleteRule: .cascade, inverse: \Transportation.cityVisit)
    var transportations: [Transportation]?
    
    // REQUIRED: Parent country visit - every city visit must be part of a country trip
    @Relationship(inverse: \CountryVisit.cityVisits)
    var parentCountryVisit: CountryVisit

    // MARK: - Convenience Initializers
    
    /// Creates a single-day exact date visit
    init(date: Date, companion: String? = nil, note: String? = nil, places: [String]? = nil, city: City? = nil, parentCountryVisit: CountryVisit) {
        self.id = UUID()
        self.datePrecision = .exact
        self.startDate = date
        self.endDate = date  // Same day
        self.companion = companion
        self.note = note
        self.places = places
        self.city = city
        self.parentCountryVisit = parentCountryVisit
    }
    
    /// Creates a date range visit (exact dates)
    init(startDate: Date, endDate: Date, companion: String? = nil, note: String? = nil, places: [String]? = nil, city: City? = nil, parentCountryVisit: CountryVisit) {
        self.id = UUID()
        self.datePrecision = .exact
        self.startDate = startDate
        self.endDate = endDate
        self.companion = companion
        self.note = note
        self.places = places
        self.city = city
        self.parentCountryVisit = parentCountryVisit
    }
    
    /// Creates a year or year range visit
    init(startYear: Int, endYear: Int? = nil, companion: String? = nil, note: String? = nil, places: [String]? = nil, city: City? = nil, parentCountryVisit: CountryVisit) {
        self.id = UUID()
        self.datePrecision = .year
        self.startYear = startYear
        self.endYear = endYear ?? startYear
        self.companion = companion
        self.note = note
        self.places = places
        self.city = city
        self.parentCountryVisit = parentCountryVisit
    }
    
    // MARK: - Display Properties
    
    /// Returns the most representative date for this visit (used for sorting)
    /// Always returns the START of the range
    var displayDate: Date? {
        switch datePrecision {
        case .exact:
            return startDate
            
        case .year:
            guard let year = startYear else { return nil }
            var components = DateComponents()
            components.year = year
            components.month = 1
            components.day = 1
            return Calendar.current.date(from: components)
        }
    }
    
    /// Returns whether this is a range (multi-day or multi-year)
    var isRange: Bool {
        switch datePrecision {
        case .exact:
            guard let start = startDate, let end = endDate else { return false }
            return !Calendar.current.isDate(start, inSameDayAs: end)
            
        case .year:
            guard let start = startYear, let end = endYear else { return false }
            return start != end
        }
    }
    
    /// Returns a formatted string based on date precision and range
    var formattedDateString: String {
        switch datePrecision {
        case .exact:
            guard let start = startDate else { return "Unknown date" }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            // Check if it's a range
            if let end = endDate, !Calendar.current.isDate(start, inSameDayAs: end) {
                return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
            }
            return formatter.string(from: start)
            
        case .year:
            guard let start = startYear else { return "Unknown year" }
            
            // Check if it's a range
            if let end = endYear, start != end {
                return "\(start)–\(end)"
            }
            return String(start)
        }
    }
    
    /// Returns a short duration description (e.g., "3 days", "2 months", "5 years")
    var durationDescription: String? {
        guard isRange else { return nil }
        
        switch datePrecision {
        case .exact:
            guard let start = startDate, let end = endDate else { return nil }
            let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
            let nights = days
            if nights == 1 {
                return "2 days, 1 night"
            } else if nights > 1 {
                return "\(nights + 1) days, \(nights) nights"
            }
            return nil
            
        case .year:
            guard let start = startYear, let end = endYear, start != end else { return nil }
            let years = end - start + 1
            return years == 1 ? "1 year" : "\(years) years"
        }
    }
    
    // MARK: - Transportation Helpers
    
    /// Returns sorted transportation records (sorted by date)
    var sortedTransportations: [Transportation] {
        guard let transportations = transportations else { return [] }
        return transportations.sorted { lhs, rhs in
            // Get comparable dates from each transportation
            let lhsDate = lhs.comparableDate
            let rhsDate = rhs.comparableDate
            
            // If both have dates, compare them
            if let leftDate = lhsDate, let rightDate = rhsDate {
                return leftDate < rightDate
            }
            
            // If only one has a date, prioritize the one with a date
            if lhsDate != nil { return true }
            if rhsDate != nil { return false }
            
            // If neither has a date, maintain original order
            return false
        }
    }
    
    /// Returns whether this visit has any transportation records
    var hasTransportation: Bool {
        guard let transportations = transportations else { return false }
        return !transportations.isEmpty
    }
    
    /// Returns the count of transportation records
    var transportationCount: Int {
        transportations?.count ?? 0
    }
    
    /// Returns a summary of all transportation (e.g., "3 flights, 1 train")
    var transportationSummary: String? {
        guard let transportations = transportations, !transportations.isEmpty else {
            return nil
        }
        
        var modeCounts: [TransportMode: Int] = [:]
        for transport in transportations {
            modeCounts[transport.mode, default: 0] += 1
        }
        
        let summaries = modeCounts.map { mode, count in
            let label = count == 1 ? mode.label : mode.pluralLabel
            return "\(count) \(label.lowercased())"
        }
        
        return summaries.joined(separator: ", ")
    }
}

// MARK: - Transportation Extension for Comparable Date

private extension Transportation {
    /// Returns a date that can be used for sorting, regardless of precision
    var comparableDate: Date? {
        switch precision {
        case .exact:
            return date
        case .year:
            guard let year = approxYear else { return nil }
            var components = DateComponents()
            components.year = year
            components.month = 1
            components.day = 1
            return Calendar.current.date(from: components)
        }
    }
}

// MARK: - TransportMode Extension for Plural

private extension TransportMode {
    /// Returns the plural form of the mode label
    var pluralLabel: String {
        switch self {
        case .flight: return "Flights"
        case .train: return "Trains"
        case .cruise: return "Cruises"
        case .car: return "Cars"
        }
    }
}

