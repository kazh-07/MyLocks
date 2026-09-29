import Foundation
import SwiftData

@Model
final class MichelinRestaurant {
    @Attribute(.unique) var id: UUID
    var name: String
    var chineseName: String?
    var city: City?
    var country: Country?
    var isChina: Bool
    /// 0 = Michelin Guide / selected, 1–3 = Michelin star level.
    var michelinLevel: Int
    /// Rating out of 10
    var rating: Double?
    var cuisine: String?
    var cuisineChinese: String?
    var thumbnailURL: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \RestaurantVisit.restaurant)
    var visits: [RestaurantVisit] = []
    
    @Relationship(deleteRule: .cascade, inverse: \RestaurantWishlist.restaurant)
    var wishlists: [RestaurantWishlist] = []

    init(
        name: String,
        chineseName: String? = nil,
        city: City? = nil,
        country: Country? = nil,
        isChina: Bool = false,
        michelinLevel: Int = 0,
        rating: Double? = nil,
        cuisine: String? = nil,
        cuisineChinese: String? = nil,
        thumbnailURL: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.chineseName = chineseName
        self.city = city
        self.country = country
        self.isChina = isChina
        self.michelinLevel = min(max(michelinLevel, 0), 3)
        self.rating = rating
        self.cuisine = cuisine
        self.cuisineChinese = cuisineChinese
        self.thumbnailURL = thumbnailURL
        self.createdAt = Date()
    }

    var isVisited: Bool { !visits.isEmpty }
    var isWishlisted: Bool { !wishlists.isEmpty }
    
    var wishlistStatus: WishlistStatus {
        if isVisited { return .visited }
        if isWishlisted { return .wishlisted }
        return .notVisited
    }
    
    var firstVisitDate: Date? { visits.compactMap(\.date).min() }
    var lastVisitDate: Date? { visits.compactMap(\.date).max() }
    var wishlistAddedDate: Date? { wishlists.map(\.addedAt).min() }
    
    // MARK: - Localized Name
    
    func localizedName(language: String) -> String {
        if language == "Chinese", let chineseName = chineseName {
            return chineseName
        }
        return name
    }
    
    func localizedCuisine(language: String) -> String? {
        if language == "Chinese", let cuisineChinese = cuisineChinese {
            return cuisineChinese
        }
        return cuisine
    }
}
