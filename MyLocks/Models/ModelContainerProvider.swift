import Foundation
import SwiftData

enum ModelContainerProvider {
    static let shared: ModelContainer = {
        let schema = Schema([
            Country.self,
            CountryVisit.self,
            CountryWishlist.self,
            City.self,
            CityVisit.self,
            CityWishlist.self,
            MichelinRestaurant.self,
            RestaurantVisit.self,
            RestaurantWishlist.self,
            Event.self,
            EventVisit.self,
            EventWishlist.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create My Locks model container: \(error)")
        }
    }()
}
