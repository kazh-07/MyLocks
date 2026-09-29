import Foundation
import SwiftData

@Model
final class CountryWishlist {
    @Attribute(.unique) var id: UUID
    var addedAt: Date
    var note: String?
    var priority: Int? // 1 = high, 2 = medium, 3 = low
    
    var country: Country?
    
    init(
        country: Country,
        note: String? = nil,
        priority: Int? = nil
    ) {
        self.id = UUID()
        self.country = country
        self.addedAt = Date()
        self.note = note
        self.priority = priority
    }
}
