import Foundation
import SwiftData

/// Transportation mode options
enum TransportMode: String, Codable, CaseIterable, Identifiable {
    case flight = "Flight"
    case train = "Train"
    case cruise = "Cruise"
    case car = "Car"
    
    var id: String { rawValue }
    
    var label: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .flight: return "airplane"
        case .train: return "train.side.front.car"
        case .cruise: return "ferry"
        case .car: return "car"
        }
    }
}

/// Transportation record linked to a city visit
@Model
final class Transportation {
    @Attribute(.unique) var id: UUID
    
    var mode: TransportMode
    var precision: DatePrecision
    var date: Date?
    var approxYear: Int?
    var approxYearStart: Int?
    var approxYearEnd: Int?
    
    // Route information
    var fromLocation: String?
    var toLocation: String?
    
    // Mode-specific details
    var carrier: String?  // airline/operator/cruise line
    var identifier: String?  // flight number/ship name/vehicle type
    
    // Relationship to city visit
    var cityVisit: CityVisit?
    
    init(
        mode: TransportMode,
        precision: DatePrecision = .exact,
        date: Date? = nil,
        approxYear: Int? = nil,
        approxYearStart: Int? = nil,
        approxYearEnd: Int? = nil,
        fromLocation: String? = nil,
        toLocation: String? = nil,
        carrier: String? = nil,
        identifier: String? = nil,
        cityVisit: CityVisit? = nil
    ) {
        self.id = UUID()
        self.mode = mode
        self.precision = precision
        self.date = date
        self.approxYear = approxYear
        self.approxYearStart = approxYearStart
        self.approxYearEnd = approxYearEnd
        self.fromLocation = fromLocation
        self.toLocation = toLocation
        self.carrier = carrier
        self.identifier = identifier
        self.cityVisit = cityVisit
    }
    
    /// Returns a formatted string based on date precision
    var displayDateString: String {
        switch precision {
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
    
    /// Returns a summary of the route
    var routeSummary: String {
        let from = fromLocation ?? "Unknown"
        let to = toLocation ?? "Unknown"
        return "\(from) → \(to)"
    }
}
