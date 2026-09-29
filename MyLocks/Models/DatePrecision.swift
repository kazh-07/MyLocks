import Foundation

/// Represents the precision level for dates in city visits
/// Restaurant visits always use exact dates only
enum DatePrecision: String, Codable, Identifiable {
    case exact = "Exact"     // Specific day or day range
    case year = "Year"       // Specific year or year range
    
    var id: String { rawValue }
    
    /// Returns all cases
    static var allCases: [DatePrecision] {
        return [.exact, .year]
    }
    
    var label: String {
        switch self {
        case .exact:
            return "Day"
        case .year:
            return "Year"
        }
    }
    
    var rangeLabel: String {
        switch self {
        case .exact:
            return "Date Range"
        case .year:
            return "Year Range"
        }
    }
}
