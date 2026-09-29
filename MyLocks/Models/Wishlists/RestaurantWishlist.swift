import Foundation
import SwiftData

@Model
final class RestaurantWishlist {
    @Attribute(.unique) var id: UUID
    var addedAt: Date
    var note: String?
    var priority: Int? // 1 = high, 2 = medium, 3 = low
    var signatureDishes: [String]?
    
    var restaurant: MichelinRestaurant?
    
    init(
        restaurant: MichelinRestaurant,
        note: String? = nil,
        priority: Int? = nil,
        signatureDishes: [String]? = nil
    ) {
        self.id = UUID()
        self.restaurant = restaurant
        self.addedAt = Date()
        self.note = note
        self.priority = priority
        self.signatureDishes = signatureDishes
    }
}
