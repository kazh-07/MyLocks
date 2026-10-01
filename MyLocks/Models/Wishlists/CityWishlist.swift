import Foundation
import SwiftData

@Model
final class CityWishlist {
    @Attribute(.unique) var id: UUID
    var addedAt: Date
    var note: String?
    var priority: Int  // 1 = high, 2 = medium, 3 = low
    var places: [String]?  // Places you want to visit in the city
    
    var city: City?
    
    init(
        city: City? = nil,
        note: String? = nil,
        priority: Int = 2,
        places: [String]? = nil
    ) {
        self.id = UUID()
        self.addedAt = Date()
        self.city = city
        self.note = note
        self.priority = priority
        self.places = places
    }
    
    // MARK: - Display Properties
    
    var priorityLabel: String {
        switch priority {
        case 1: return "High"
        case 2: return "Medium"
        case 3: return "Low"
        default: return "Medium"
        }
    }
    
    var priorityEmoji: String {
        switch priority {
        case 1: return "⭐️"
        case 2: return "⚡️"
        case 3: return "💭"
        default: return "⚡️"
        }
    }
}
