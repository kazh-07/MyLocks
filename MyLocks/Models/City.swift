import Foundation
import SwiftData

@Model
final class City {
    @Attribute(.unique) var id: UUID
    var name: String
    var chineseName: String?
    var country: Country?
    var isChina: Bool
    var cityTier: Int?
    var province: String?
    var provinceChinese: String?
    var thumbnailURL: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CityVisit.city)
    var visits: [CityVisit] = []
    
    @Relationship(deleteRule: .cascade, inverse: \CityWishlist.city)
    var wishlists: [CityWishlist] = []

    init(
        name: String,
        chineseName: String? = nil,
        country: Country? = nil,
        isChina: Bool = false,
        cityTier: Int? = nil,
        province: String? = nil,
        provinceChinese: String? = nil,
        thumbnailURL: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.chineseName = chineseName
        self.country = country
        self.isChina = isChina
        self.cityTier = cityTier
        self.province = province
        self.provinceChinese = provinceChinese
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
    
    /// Places from visits - places you've actually been to
    var visitedPlaces: [String] {
        var placesSet = Set<String>()
        
        visits.forEach { visit in
            if let visitPlaces = visit.places {
                visitPlaces.forEach { placesSet.insert($0) }
            }
        }
        
        return Array(placesSet).sorted()
    }
    
    /// Places from wishlists - places you want to visit
    var wishlistPlaces: [String] {
        var placesSet = Set<String>()
        
        wishlists.forEach { wishlist in
            if let wishlistPlaces = wishlist.places {
                wishlistPlaces.forEach { placesSet.insert($0) }
            }
        }
        
        return Array(placesSet).sorted()
    }
    
    /// All unique places from both visits and wishlists
    var allPlaces: [String] {
        var placesSet = Set<String>()
        
        // Add places from visits
        visits.forEach { visit in
            if let visitPlaces = visit.places {
                visitPlaces.forEach { placesSet.insert($0) }
            }
        }
        
        // Add places from wishlists
        wishlists.forEach { wishlist in
            if let wishlistPlaces = wishlist.places {
                wishlistPlaces.forEach { placesSet.insert($0) }
            }
        }
        
        return Array(placesSet).sorted()
    }
    
    // MARK: - Localized Name
    
    func localizedName(language: String) -> String {
        if language == "Chinese", let chineseName = chineseName {
            return chineseName
        }
        return name
    }
    
    // MARK: - Localized Province
    
    func localizedProvince(language: String) -> String? {
        if language == "Chinese", let provinceChinese = provinceChinese {
            return provinceChinese
        }
        return province
    }
    
    // MARK: - Localized City Tier
    
    func localizedCityTier(language: String) -> String? {
        guard let tier = cityTier else { return nil }
        
        if language == "Chinese" {
            switch tier {
            case 0:
                return "超一线城市"
            case 1:
                return "新一线城市"
            case 2:
                return "二线城市"
            case 3:
                return "三线城市"
            default:
                return "Tier \(tier)"
            }
        } else {
            return "Tier \(tier)"
        }
    }
}
