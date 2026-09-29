import Foundation

// MARK: - Sorting Extension for City

extension City {
    /// Sorts visited cities by most recent visit date (newest first)
    static func sortedByRecentVisit(_ cities: [City]) -> [City] {
        cities.sorted { city1, city2 in
            guard let date1 = city1.lastVisitDate else { return false }
            guard let date2 = city2.lastVisitDate else { return true }
            return date1 > date2
        }
    }
    
    /// Sorts wishlisted cities by priority (high to low), then by date added (newest first)
    static func sortedByWishlistPriority(_ cities: [City]) -> [City] {
        cities.sorted { city1, city2 in
            // Get priority for each city (lower number = higher priority)
            let priority1 = city1.wishlists.compactMap(\.priority).min() ?? Int.max
            let priority2 = city2.wishlists.compactMap(\.priority).min() ?? Int.max
            
            // If priorities are different, sort by priority
            if priority1 != priority2 {
                return priority1 < priority2
            }
            
            // If priorities are the same, sort by most recently added
            guard let date1 = city1.wishlistAddedDate else { return false }
            guard let date2 = city2.wishlistAddedDate else { return true }
            return date1 > date2
        }
    }
}

// MARK: - Sorting Extension for MichelinRestaurant

extension MichelinRestaurant {
    /// Sorts visited restaurants by most recent visit date (newest first)
    static func sortedByRecentVisit(_ restaurants: [MichelinRestaurant]) -> [MichelinRestaurant] {
        restaurants.sorted { restaurant1, restaurant2 in
            guard let date1 = restaurant1.lastVisitDate else { return false }
            guard let date2 = restaurant2.lastVisitDate else { return true }
            return date1 > date2
        }
    }
    
    /// Sorts visited restaurants by highest rating (based on visit ratings)
    static func sortedByRating(_ restaurants: [MichelinRestaurant]) -> [MichelinRestaurant] {
        restaurants.sorted { restaurant1, restaurant2 in
            // Get highest rating from all visits
            let rating1 = restaurant1.visits.compactMap(\.rating).max() ?? 0
            let rating2 = restaurant2.visits.compactMap(\.rating).max() ?? 0
            
            // If ratings are different, sort by rating
            if rating1 != rating2 {
                return rating1 > rating2
            }
            
            // If ratings are the same, sort by most recent visit
            guard let date1 = restaurant1.lastVisitDate else { return false }
            guard let date2 = restaurant2.lastVisitDate else { return true }
            return date1 > date2
        }
    }
    
    /// Sorts wishlisted restaurants by priority (high to low), then by date added (newest first)
    static func sortedByWishlistPriority(_ restaurants: [MichelinRestaurant]) -> [MichelinRestaurant] {
        restaurants.sorted { restaurant1, restaurant2 in
            // Get priority for each restaurant (lower number = higher priority)
            let priority1 = restaurant1.wishlists.compactMap(\.priority).min() ?? Int.max
            let priority2 = restaurant2.wishlists.compactMap(\.priority).min() ?? Int.max
            
            // If priorities are different, sort by priority
            if priority1 != priority2 {
                return priority1 < priority2
            }
            
            // If priorities are the same, sort by most recently added
            guard let date1 = restaurant1.wishlistAddedDate else { return false }
            guard let date2 = restaurant2.wishlistAddedDate else { return true }
            return date1 > date2
        }
    }
}
