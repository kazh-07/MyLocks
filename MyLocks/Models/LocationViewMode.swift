import Foundation

/// Represents the view mode for location displays (cities vs countries)
enum LocationViewMode: String, Codable, Identifiable, CaseIterable, Hashable {
    case cities = "Cities"
    case countries = "Countries"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .cities:
            return "Cities"
        case .countries:
            return "Countries"
        }
    }
    
    var icon: String {
        switch self {
        case .cities:
            return "building.2"
        case .countries:
            return "globe"
        }
    }
}
