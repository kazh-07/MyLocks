import Foundation

// MARK: - Sorting Extension for Country

extension Country {
    /// Sorts visited countries by most recent visit date (newest first)
    static func sortedByRecentVisit(_ countries: [Country]) -> [Country] {
        countries.sorted { country1, country2 in
            guard let date1 = country1.lastVisitDate else { return false }
            guard let date2 = country2.lastVisitDate else { return true }
            return date1 > date2
        }
    }
    
    /// Sorts wishlisted countries by priority (high to low), then by date added (newest first)
    static func sortedByWishlistPriority(_ countries: [Country]) -> [Country] {
        countries.sorted { country1, country2 in
            // Get priority for each country (lower number = higher priority)
            let priority1 = country1.wishlists.compactMap(\.priority).min() ?? Int.max
            let priority2 = country2.wishlists.compactMap(\.priority).min() ?? Int.max
            
            // If priorities are different, sort by priority
            if priority1 != priority2 {
                return priority1 < priority2
            }
            
            // If priorities are the same, sort by most recently added
            guard let date1 = country1.wishlistAddedDate else { return false }
            guard let date2 = country2.wishlistAddedDate else { return true }
            return date1 > date2
        }
    }
    
    /// Sorts countries by number of visited cities (most to least)
    static func sortedByCityCount(_ countries: [Country]) -> [Country] {
        countries.sorted { country1, country2 in
            let cityCount1 = country1.cities.filter { $0.isVisited }.count
            let cityCount2 = country2.cities.filter { $0.isVisited }.count
            
            if cityCount1 != cityCount2 {
                return cityCount1 > cityCount2
            }
            
            // If city counts are the same, sort by most recent visit
            guard let date1 = country1.lastVisitDate else { return false }
            guard let date2 = country2.lastVisitDate else { return true }
            return date1 > date2
        }
    }
}
