import Foundation
import SwiftData

@Model
final class CityWishlist {
    @Attribute(.unique) var id: UUID
    var addedAt: Date
    var note: String?
    var priority: Int? // 1 = high, 2 = medium, 3 = low
    var places: [String]? // Places you want to visit in the city
    
    var city: City?
    
    init(
        city: City,
        note: String? = nil,
        priority: Int? = nil,
        places: [String]? = nil
    ) {
        self.id = UUID()
        self.city = city
        self.addedAt = Date()
        self.note = note
        self.priority = priority
        self.places = places
    }
}
