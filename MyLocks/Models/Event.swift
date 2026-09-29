import Foundation
import SwiftData

@Model
final class Event {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var city: String?
    var country: String?
    var createdAt: Date
    var note: String?

    @Relationship(deleteRule: .cascade, inverse: \EventVisit.event)
    var visits: [EventVisit] = []
    
    @Relationship(deleteRule: .cascade, inverse: \EventWishlist.event)
    var wishlists: [EventWishlist] = []

    init(
        name: String,
        category: String = "Other",
        city: String? = nil,
        country: String? = nil,
        note: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.city = city
        self.country = country
        self.createdAt = Date()
        self.note = note
    }

    var isVisited: Bool { !visits.isEmpty }
    var isWishlisted: Bool { !wishlists.isEmpty }
    
    var wishlistStatus: WishlistStatus {
        if isVisited { return .visited }
        if isWishlisted { return .wishlisted }
        return .notVisited
    }
    
    var firstVisitDate: Date? { visits.map(\.date).min() }
    var lastVisitDate: Date? { visits.map(\.date).max() }
    var wishlistAddedDate: Date? { wishlists.map(\.addedAt).min() }
}
