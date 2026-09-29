import Foundation
import SwiftData

@Model
final class RestaurantVisit {
    @Attribute(.unique) var id: UUID
    var date: Date?
    var companion: String?
    var note: String?
    /// User rating from 1 to 5 hearts. Nil means not rated.
    var rating: Int?
    var signatureDishes: [String]?
    var restaurant: MichelinRestaurant?

    init(
        date: Date? = nil,
        companion: String? = nil,
        note: String? = nil,
        rating: Int? = nil,
        signatureDishes: [String]? = nil,
        restaurant: MichelinRestaurant? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.companion = companion
        self.note = note
        self.rating = rating.map { min(max($0, 1), 5) }
        self.signatureDishes = signatureDishes
        self.restaurant = restaurant
    }
}
