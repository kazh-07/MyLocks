import Foundation
import SwiftData

@Model
final class Country {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var code: String
    var name: String
    var chineseName: String?
    var nativeName: String?
    var flagEmoji: String?
    var continent: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CountryVisit.country)
    var visits: [CountryVisit] = []
    
    @Relationship(deleteRule: .cascade, inverse: \CountryWishlist.country)
    var wishlists: [CountryWishlist] = []

    @Relationship(inverse: \City.country)
    var cities: [City] = []

    @Relationship(inverse: \MichelinRestaurant.country)
    var restaurants: [MichelinRestaurant] = []

    init(
        name: String,
        code: String,
        chineseName: String? = nil,
        nativeName: String? = nil,
        flagEmoji: String? = nil,
        continent: String? = nil
    ) {
        self.id = UUID()
        self.code = code.uppercased()
        self.name = name
        self.chineseName = chineseName
        self.nativeName = nativeName
        self.flagEmoji = flagEmoji
        self.continent = continent
        self.createdAt = Date()
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
    
    // MARK: - Localized Name
    
    func localizedName(language: String) -> String {
        if language == "Chinese", let chineseName = chineseName {
            return chineseName
        }
        return name
    }
}
