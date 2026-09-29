import Foundation

/// Represents the precision level for dates in trips and visits
enum DatePrecision: String, Codable, CaseIterable, Identifiable {
    case exact = "Exact"
    case month = "Month"
    case year = "Year"
    case yearRange = "Year Range"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .exact:
            return "Exact"
        case .month:
            return "Month"
        case .year:
            return "Year"
        case .yearRange:
            return "Range"
        }
    }
}
