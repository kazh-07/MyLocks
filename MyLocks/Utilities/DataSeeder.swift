import Foundation
import SwiftData

enum DataSeeder {
    static func seedIfNeeded(from container: ModelContainer) async {
        let context = ModelContext(container)
        context.autosaveEnabled = false

        // Check if we’ve already seeded (by looking for any Country)
        let countryFetch = FetchDescriptor<Country>()
        if let existing = try? context.fetch(countryFetch), existing.isEmpty == false {
            // DEVELOPMENT MODE: Delete and re-seed instead of migrating
            print("🔄 Development mode: Clearing existing data and re-seeding...")
            
            let cityFetch = FetchDescriptor<City>()
            let restaurantFetch = FetchDescriptor<MichelinRestaurant>()
            
            if let cities = try? context.fetch(cityFetch) {
                for city in cities { context.delete(city) }
            }
            if let countries = try? context.fetch(countryFetch) {
                for country in countries { context.delete(country) }
            }
            if let restaurants = try? context.fetch(restaurantFetch) {
                for restaurant in restaurants { context.delete(restaurant) }
            }
            
            try? context.save()
            print("✅ Cleared all existing data")
            // Continue to re-seed below...
        }

        // Import all countries using iOS built-in data
        var countryMap: [String: Country] = [:]
        let allCountries = CountryDataProvider.allCountries()
        
        for countryData in allCountries {
            // Add Chinese names for common countries
            var chineseName: String?
            switch countryData.code {
            case "CN": chineseName = "中国"
            case "US": chineseName = "美国"
            case "JP": chineseName = "日本"
            case "FR": chineseName = "法国"
            case "GB": chineseName = "英国"
            case "IT": chineseName = "意大利"
            case "ES": chineseName = "西班牙"
            case "DE": chineseName = "德国"
            case "KR": chineseName = "韩国"
            case "TH": chineseName = "泰国"
            case "SG": chineseName = "新加坡"
            case "HK": chineseName = "香港"
            case "MO": chineseName = "澳门"
            case "TW": chineseName = "台湾"
            default: break
            }
            
            let country = Country(
                name: countryData.name,
                code: countryData.code,
                chineseName: chineseName,
                nativeName: countryData.nativeName,
                flagEmoji: countryData.flagEmoji,
                continent: countryData.continent
            )
            context.insert(country)
            countryMap[countryData.code] = country
        }
        
        // Import all Chinese cities first (before restaurants, so cityMap exists)
        let chineseCities = await ChineseCitiesDataProvider.allChineseCitiesAsync()
        var cityMap: [String: City] = [:] // Key: city name for easy lookup
        
        for cityData in chineseCities {
            guard let country = countryMap[cityData.countryCode] else {
                print("Warning: Country not found for code: \(cityData.countryCode)")
                continue
            }
            
            let city = City(
                name: cityData.name,
                chineseName: cityData.chineseName,
                country: country,
                isChina: cityData.countryCode == "CN" || cityData.countryCode == "HK" || cityData.countryCode == "MO",
                cityTier: cityData.tier,
                province: cityData.province,
                provinceChinese: cityData.provinceChinese,
                thumbnailURL: cityData.thumbnailURL
            )
            context.insert(city)
            cityMap[cityData.name] = city
        }
        
        // Add some other major international cities
        if let usa = countryMap["US"],
           let france = countryMap["FR"],
           let japan = countryMap["JP"],
           let uk = countryMap["GB"],
           let spain = countryMap["ES"],
           let italy = countryMap["IT"],
           let singapore = countryMap["SG"] {
            
            let internationalCities = [
                City(name: "New York", chineseName: "纽约", country: usa, isChina: false, cityTier: nil),
                City(name: "San Francisco", chineseName: "旧金山", country: usa, isChina: false, cityTier: nil),
                City(name: "Los Angeles", chineseName: "洛杉矶", country: usa, isChina: false, cityTier: nil),
                City(name: "Chicago", chineseName: "芝加哥", country: usa, isChina: false, cityTier: nil),
                City(name: "Paris", chineseName: "巴黎", country: france, isChina: false, cityTier: nil),
                City(name: "Tokyo", chineseName: "东京", country: japan, isChina: false, cityTier: nil),
                City(name: "London", chineseName: "伦敦", country: uk, isChina: false, cityTier: nil),
                City(name: "Barcelona", chineseName: "巴塞罗那", country: spain, isChina: false, cityTier: nil),
                City(name: "Rome", chineseName: "罗马", country: italy, isChina: false, cityTier: nil),
                City(name: "Singapore", chineseName: "新加坡", country: singapore, isChina: false, cityTier: nil),
            ]
            
            for city in internationalCities {
                context.insert(city)
                cityMap[city.name] = city
            }
        }
        
        // Import Michelin restaurants (after cities, so cityMap is populated)
        let restaurantData = await MichelinDataProvider.loadRestaurantsAsync()
        var restaurantMap: [String: MichelinRestaurant] = [:] // Key: restaurant name for easy lookup
        
        for data in restaurantData {
            guard let country = countryMap[data.countryCode] else {
                print("Warning: Country not found for code: \(data.countryCode)")
                continue
            }
            
            // Try to find matching city from cityMap, or create a new one if needed
            var restaurantCity: City? = cityMap[data.city]
            
            // If city doesn't exist yet, create it
            if restaurantCity == nil {
                let newCity = City(
                    name: data.city,
                    chineseName: nil, // Will be filled in if we have the data
                    country: country,
                    isChina: data.countryCode == "CN" || data.countryCode == "HK" || data.countryCode == "MO",
                    cityTier: nil,
                    province: nil,
                    provinceChinese: nil
                )
                context.insert(newCity)
                cityMap[data.city] = newCity
                restaurantCity = newCity
            }
            
            let restaurant = MichelinRestaurant(
                name: data.name,
                chineseName: data.chineseName,
                city: restaurantCity,
                country: country,
                isChina: data.countryCode == "CN" || data.countryCode == "HK" || data.countryCode == "MO",
                michelinLevel: data.michelinLevel,
                rating: nil, // Can be added by user later
                cuisine: data.cuisine,
                cuisineChinese: data.cuisineChinese,
                thumbnailURL: data.thumbnailURL
            )
            context.insert(restaurant)
            restaurantMap[data.name] = restaurant
        }
        
        // Add sample visits and wishlists for demo purposes
        addSampleData(
            context: context,
            cityMap: cityMap,
            restaurantMap: restaurantMap,
            countryMap: countryMap
        )

        do {
            try context.save()
            
            // Count cities with thumbnails for verification
            let citiesWithThumbnails = cityMap.values.filter { $0.thumbnailURL != nil }.count
            
            print("✅ Successfully seeded:")
            print("   • \(allCountries.count) countries")
            print("   • \(chineseCities.count) Chinese cities")
            print("   • \(cityMap.count) total cities")
            print("   • \(citiesWithThumbnails) cities with thumbnail URLs")
            print("   • \(restaurantData.count) restaurants")
        } catch {
            // If anything fails, we silently ignore to avoid crashing in production.
            // Consider logging this in development.
            print("❌ Seeding failed: \(error)")
        }
    }
    
    /// Refresh data from remote sources (Google Sheets and Google Drive)
    static func refreshRestaurantData(from container: ModelContainer) async throws {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        
        print("🔄 Refreshing data from remote sources...")
        
        // Fetch updated Chinese cities from Google Drive
        let updatedCityData = await ChineseCitiesDataProvider.allChineseCitiesAsync()
        
        // Fetch updated restaurant data from Google Sheets
        let updatedRestaurantData = await MichelinDataProvider.loadRestaurantsAsync()
        
        if updatedRestaurantData.isEmpty {
            throw RefreshError.noDataLoaded
        }
        
        // Get existing maps for countries and cities
        let countryFetch = FetchDescriptor<Country>()
        let countries = try context.fetch(countryFetch)
        var countryMap: [String: Country] = [:]
        for country in countries {
            countryMap[country.code] = country
        }
        
        let cityFetch = FetchDescriptor<City>()
        let existingCities = try context.fetch(cityFetch)
        var cityMap: [String: City] = [:]
        for city in existingCities {
            cityMap[city.name] = city
        }
        
        // Update or create cities from Chinese cities data
        var newCityCount = 0
        var updatedCityCount = 0
        
        for cityData in updatedCityData {
            guard let country = countryMap[cityData.countryCode] else {
                print("⚠️ Country not found for code: \(cityData.countryCode)")
                continue
            }
            
            if let existingCity = cityMap[cityData.name] {
                // Update existing city
                existingCity.chineseName = cityData.chineseName
                existingCity.cityTier = cityData.tier
                existingCity.province = cityData.province
                existingCity.provinceChinese = cityData.provinceChinese
                updatedCityCount += 1
            } else {
                // Create new city
                let newCity = City(
                    name: cityData.name,
                    chineseName: cityData.chineseName,
                    country: country,
                    isChina: cityData.countryCode == "CN" || cityData.countryCode == "HK" || cityData.countryCode == "MO",
                    cityTier: cityData.tier,
                    province: cityData.province,
                    provinceChinese: cityData.provinceChinese
                )
                context.insert(newCity)
                cityMap[cityData.name] = newCity
                newCityCount += 1
            }
        }
        
        // Get existing restaurants
        let restaurantFetch = FetchDescriptor<MichelinRestaurant>()
        let existingRestaurants = try context.fetch(restaurantFetch)
        var existingRestaurantMap: [String: MichelinRestaurant] = [:]
        for restaurant in existingRestaurants {
            existingRestaurantMap[restaurant.name] = restaurant
        }
        
        var newRestaurantCount = 0
        var updatedRestaurantCount = 0
        
        // Update or create restaurants
        for data in updatedRestaurantData {
            guard let country = countryMap[data.countryCode] else {
                print("⚠️ Country not found for code: \(data.countryCode)")
                continue
            }
            
            // Find or create city
            var restaurantCity: City? = cityMap[data.city]
            if restaurantCity == nil {
                let newCity = City(
                    name: data.city,
                    chineseName: nil,
                    country: country,
                    isChina: data.countryCode == "CN" || data.countryCode == "HK" || data.countryCode == "MO",
                    cityTier: nil,
                    province: nil,
                    provinceChinese: nil
                )
                context.insert(newCity)
                cityMap[data.city] = newCity
                restaurantCity = newCity
            }
            
            // Check if restaurant already exists
            if let existingRestaurant = existingRestaurantMap[data.name] {
                // Update existing restaurant
                existingRestaurant.chineseName = data.chineseName
                existingRestaurant.city = restaurantCity
                existingRestaurant.country = country
                existingRestaurant.michelinLevel = data.michelinLevel
                existingRestaurant.cuisine = data.cuisine
                existingRestaurant.cuisineChinese = data.cuisineChinese
                existingRestaurant.thumbnailURL = data.thumbnailURL
                updatedRestaurantCount += 1
            } else {
                // Create new restaurant
                let restaurant = MichelinRestaurant(
                    name: data.name,
                    chineseName: data.chineseName,
                    city: restaurantCity,
                    country: country,
                    isChina: data.countryCode == "CN" || data.countryCode == "HK" || data.countryCode == "MO",
                    michelinLevel: data.michelinLevel,
                    rating: nil,
                    cuisine: data.cuisine,
                    cuisineChinese: data.cuisineChinese,
                    thumbnailURL: data.thumbnailURL
                )
                context.insert(restaurant)
                newRestaurantCount += 1
            }
        }
        
        try context.save()
        print("✅ Data refresh complete:")
        print("   • Cities: \(newCityCount) new, \(updatedCityCount) updated")
        print("   • Restaurants: \(newRestaurantCount) new, \(updatedRestaurantCount) updated")
    }
    
    enum RefreshError: Error {
        case noDataLoaded
    }
    
    // MARK: - Sample Data
    
    private static func addSampleData(
        context: ModelContext,
        cityMap: [String: City],
        restaurantMap: [String: MichelinRestaurant],
        countryMap: [String: Country]
    ) {
        // Get some cities
        guard let shanghai = cityMap["Shanghai"],
              let beijing = cityMap["Beijing"],
              let hongKong = cityMap["Hong Kong"],
              let tokyo = cityMap["Tokyo"],
              let paris = cityMap["Paris"],
              let newYork = cityMap["New York"] else {
            print("⚠️ Sample data: Some cities not found")
            return
        }
        
        // Get some countries
        guard let china = countryMap["CN"],
              let japan = countryMap["JP"],
              let france = countryMap["FR"],
              let usa = countryMap["US"] else {
            print("⚠️ Sample data: Some countries not found")
            return
        }
        
        // === CITY VISITS (all must have a parent CountryVisit) ===
        
        // CHINA VISITS - Multiple separate trips to China
        
        // China Trip 1: Shanghai extended stay (2019-2020)
        let chinaTrip1 = CountryVisit(
            country: china,
            date: Calendar.current.date(from: DateComponents(year: 2019, month: 1, day: 15)) ?? Date(),
            notes: "Extended stay in Shanghai - year range visit"
        )
        context.insert(chinaTrip1)
        
        let shanghaiVisit1 = CityVisit(
            startYear: 2019,
            endYear: 2020,
            note: "First extended stay in Shanghai! Amazing food scene, loved the Bund area and the night skyline.",
            places: ["The Bund", "Yu Garden", "Shanghai Tower", "Nanjing Road"],
            city: shanghai,
            parentCountryVisit: chinaTrip1
        )
        context.insert(shanghaiVisit1)
        
        // Add transportation for Shanghai Visit 1 - arrival by flight
        let shanghaiArrivalFlight = Transportation(
            mode: .flight,
            precision: .exact,
            date: Calendar.current.date(from: DateComponents(year: 2019, month: 1, day: 15)),
            fromLocation: "San Francisco (SFO)",
            toLocation: "Shanghai Pudong (PVG)",
            carrier: "United Airlines",
            identifier: "UA857",
            cityVisit: shanghaiVisit1
        )
        context.insert(shanghaiArrivalFlight)
        
        // China Trip 2: Shanghai business trip
        let tripStart = Date().addingTimeInterval(-86400 * 200)
        let chinaTrip2 = CountryVisit(
            country: china,
            date: tripStart,
            notes: "Business trip to Shanghai"
        )
        context.insert(chinaTrip2)
        
        let tripEnd = Date().addingTimeInterval(-86400 * 194)  // 6 days later
        let shanghaiVisit2 = CityVisit(
            startDate: tripStart,
            endDate: tripEnd,
            companion: "Sarah",
            note: "Back for business. Had the best xiaolongbao at Din Tai Fung. The French Concession is so charming.",
            places: ["French Concession", "Tianzifang", "Xintiandi", "People's Square"],
            city: shanghai,
            parentCountryVisit: chinaTrip2
        )
        context.insert(shanghaiVisit2)
        
        // Add transportation for Shanghai Visit 2
        let shanghaiArrivalFlight2 = Transportation(
            mode: .flight,
            precision: .exact,
            date: tripStart,
            fromLocation: "Beijing Capital (PEK)",
            toLocation: "Shanghai Hongqiao (SHA)",
            carrier: "Air China",
            identifier: "CA1835",
            cityVisit: shanghaiVisit2
        )
        context.insert(shanghaiArrivalFlight2)
        
        // China Trip 3: Shanghai summer vacation (2024)
        let summer2024Start = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 15)) ?? Date()
        let chinaTrip3 = CountryVisit(
            country: china,
            date: summer2024Start,
            notes: "Summer 2024 Shanghai trip"
        )
        context.insert(chinaTrip3)
        
        let summer2024End = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 22)) ?? Date()
        let shanghaiVisit3 = CityVisit(
            startDate: summer2024Start,
            endDate: summer2024End,
            companion: "Sarah",
            note: "Third visit! Explored more local neighborhoods. Tried authentic Shanghainese cuisine in the old town.",
            places: ["Old Town", "Jing'an Temple", "M50 Art District"],
            city: shanghai,
            parentCountryVisit: chinaTrip3
        )
        context.insert(shanghaiVisit3)
        
        // China Trip 4: Beijing business trip (2022)
        let chinaTrip4 = CountryVisit(
            country: china,
            date: Calendar.current.date(from: DateComponents(year: 2022, month: 6, day: 1)) ?? Date(),
            notes: "Beijing business trip - 2022"
        )
        context.insert(chinaTrip4)
        
        let beijingVisit1 = CityVisit(
            startYear: 2022,
            endYear: 2022,  // Same year = single year visit
            note: "Business trip, visited Great Wall. The Forbidden City is breathtaking!",
            places: ["Great Wall", "Forbidden City", "Temple of Heaven"],
            city: beijing,
            parentCountryVisit: chinaTrip4
        )
        context.insert(beijingVisit1)
        
        // Add transportation for Beijing Visit 1 (year precision)
        let beijingArrivalTrain = Transportation(
            mode: .train,
            precision: .year,
            approxYear: 2022,
            fromLocation: "Shanghai Hongqiao",
            toLocation: "Beijing South",
            carrier: "China Railway High-speed",
            identifier: "G2",
            cityVisit: beijingVisit1
        )
        context.insert(beijingArrivalTrain)
        
        // China Trip 5: Beijing day trip
        let beijingDate = Date().addingTimeInterval(-86400 * 45)
        let chinaTrip5 = CountryVisit(
            country: china,
            date: beijingDate,
            notes: "Quick Beijing business meeting"
        )
        context.insert(chinaTrip5)
        
        let beijingVisit2 = CityVisit(
            date: beijingDate,  // Single day convenience init
            companion: "Work colleagues",
            note: "Quick business meeting and tried Peking duck at a famous restaurant.",
            places: ["Nanluoguxiang", "798 Art District"],
            city: beijing,
            parentCountryVisit: chinaTrip5
        )
        context.insert(beijingVisit2)
        
        // China Trip 6: Beijing weekend getaway
        let weekendStart = Date().addingTimeInterval(-86400 * 100)
        let chinaTrip6 = CountryVisit(
            country: china,
            date: weekendStart,
            notes: "Weekend trip to Beijing with friends"
        )
        context.insert(chinaTrip6)
        
        let weekendEnd = Date().addingTimeInterval(-86400 * 98)  // 2 days later
        let beijingVisit3 = CityVisit(
            startDate: weekendStart,
            endDate: weekendEnd,
            companion: "Friends",
            note: "Weekend getaway! Walked around hutongs and loved the local vibe.",
            places: ["Summer Palace", "Hutongs", "Lama Temple"],
            city: beijing,
            parentCountryVisit: chinaTrip6
        )
        context.insert(beijingVisit3)
        
        // Add transportation for Beijing Visit 3
        let beijingArrivalCar = Transportation(
            mode: .car,
            precision: .exact,
            date: weekendStart,
            fromLocation: "Tianjin",
            toLocation: "Beijing",
            carrier: "Rental Car",
            identifier: "Tesla Model 3",
            cityVisit: beijingVisit3
        )
        context.insert(beijingArrivalCar)
        
        // FRANCE VISIT - Paris extended stay
        let parisDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1)) ?? Date()
        let franceTrip = CountryVisit(
            country: france,
            date: parisDate,
            notes: "Extended stay in Paris - romantic getaway"
        )
        context.insert(franceTrip)
        
        let parisVisit = CityVisit(
            startYear: 2023,
            endYear: 2024,
            companion: "Partner",
            note: "Romantic extended stay, amazing cafes. Visited the Louvre and walked along Seine.",
            places: ["Louvre Museum", "Eiffel Tower", "Seine River", "Montmartre", "Notre-Dame"],
            city: paris,
            parentCountryVisit: franceTrip
        )
        context.insert(parisVisit)
        
        // Add transportation for Paris visit - arrival by flight (year precision since visit spans years)
        let parisArrivalFlight = Transportation(
            mode: .flight,
            precision: .year,
            approxYear: 2023,
            fromLocation: "New York (JFK)",
            toLocation: "Paris Charles de Gaulle (CDG)",
            carrier: "Air France",
            identifier: "AF007",
            cityVisit: parisVisit
        )
        context.insert(parisArrivalFlight)
        
        // === CITY WISHLISTS ===
        // Hong Kong - high priority wishlist
        context.insert(CityWishlist(
            city: hongKong,
            note: "Want to try dim sum and visit Victoria Peak",
            priority: 1,
            places: ["Victoria Peak", "Tsim Sha Tsui", "Temple Street Night Market", "Lantau Island", "Wong Tai Sin Temple"]
        ))
        
        // Tokyo - high priority wishlist
        context.insert(CityWishlist(
            city: tokyo,
            note: "Sushi pilgrimage! Also want to see cherry blossoms",
            priority: 1,
            places: ["Tsukiji Market", "Senso-ji Temple", "Shibuya Crossing", "Meiji Shrine", "Tokyo Skytree", "Akihabara"]
        ))
        
        // New York - medium priority wishlist
        context.insert(CityWishlist(
            city: newYork,
            note: "Try the famous pizza and bagels",
            priority: 2,
            places: ["Times Square", "Central Park", "Statue of Liberty", "Brooklyn Bridge", "Metropolitan Museum", "Broadway"]
        ))
        
        // === COUNTRY VISITS - Multi-city trip example ===
        
        // EXAMPLE: Multi-city country trip - One China visit with multiple city visits (Beijing + Shanghai)
        let chinaTripDate = Date().addingTimeInterval(-86400 * 60) // ~2 months ago
        let chinaMultiCityTrip = CountryVisit(
            country: china,
            date: chinaTripDate,
            notes: "Two-week trip across China - visited Beijing and Shanghai"
        )
        context.insert(chinaMultiCityTrip)
        
        // Beijing visit as part of the China country trip
        let chinaTripBeijing = CityVisit(
            startDate: chinaTripDate,
            endDate: chinaTripDate.addingTimeInterval(86400 * 5), // 5 days in Beijing
            companion: "Sarah",
            note: "First leg: Beijing - Great Wall, Forbidden City, and amazing Peking duck!",
            places: ["Forbidden City", "Great Wall", "Hutongs", "Temple of Heaven"],
            city: beijing,
            parentCountryVisit: chinaMultiCityTrip
        )
        context.insert(chinaTripBeijing)
        
        // Shanghai visit as part of the same China country trip
        let chinaTripShanghai = CityVisit(
            startDate: chinaTripDate.addingTimeInterval(86400 * 6), // Started after Beijing
            endDate: chinaTripDate.addingTimeInterval(86400 * 12), // 6 days in Shanghai
            companion: "Sarah",
            note: "Second leg: Shanghai - explored The Bund, French Concession, incredible food scene",
            places: ["The Bund", "French Concession", "Yu Garden", "Nanjing Road", "Xintiandi"],
            city: shanghai,
            parentCountryVisit: chinaMultiCityTrip
        )
        context.insert(chinaTripShanghai)
        
        // === COUNTRY WISHLISTS ===
        context.insert(CountryWishlist(
            country: japan,
            note: "Must visit for ramen and culture",
            priority: 1
        ))
        
        context.insert(CountryWishlist(
            country: usa,
            note: "Road trip across America",
            priority: 2
        ))
        
        // === RESTAURANT VISITS ===
        // Find some restaurants from the CSV data
        let shanghaiRestaurants = restaurantMap.values.filter { $0.city?.name == "Shanghai" }
        let beijingRestaurants = restaurantMap.values.filter { $0.city?.name == "Beijing" }
        let parisRestaurants = restaurantMap.values.filter { $0.city?.name == "Paris" }
        
        // Add visits to Shanghai restaurants
        if let taianTable = shanghaiRestaurants.first(where: { $0.name.contains("Taian") }) {
            context.insert(RestaurantVisit(
                date: Date().addingTimeInterval(-86400 * 365),
                companion: "Sarah",
                note: "Incredible tasting menu, every course was perfect",
                rating: 5,
                signatureDishes: ["Sea Cucumber with Black Truffle", "Wagyu Beef Tartare", "Crispy Duck", "Foie Gras with Cherry"],
                restaurant: taianTable
            ))
        }
        
        if let fu1015 = shanghaiRestaurants.first(where: { $0.name.contains("Fu 1015") }) {
            context.insert(RestaurantVisit(
                date: Date().addingTimeInterval(-86400 * 364),
                note: "Authentic Shanghainese cuisine",
                rating: 4,
                signatureDishes: ["Braised Pork Belly", "Steamed Crab", "Drunken Chicken"],
                restaurant: fu1015
            ))
        }
        
        // Add visits to Beijing restaurants
        if let xinjRongJi = beijingRestaurants.first(where: { $0.name.contains("Xin Rong Ji") && $0.michelinLevel == 3 }) {
            context.insert(RestaurantVisit(
                date: Date().addingTimeInterval(-86400 * 180),
                companion: "Business colleagues",
                note: "3-star experience! Seafood was outstanding",
                rating: 5,
                signatureDishes: ["Wild Yellow Croaker", "Taizhou Seafood", "Braised Abalone", "Sea Cucumber"],
                restaurant: xinjRongJi
            ))
        }
        
        if let jingji = beijingRestaurants.first(where: { $0.name.contains("Jingji") }) {
            context.insert(RestaurantVisit(
                date: Date().addingTimeInterval(-86400 * 179),
                note: "Beautiful Beijing cuisine presentation",
                rating: 4,
                signatureDishes: ["Peking Duck", "Imperial Court Soup", "Stir-fried Prawns"],
                restaurant: jingji
            ))
        }
        
        // Add visit to Paris restaurant
        if let arpege = parisRestaurants.first(where: { $0.name.contains("Arpège") }) {
            context.insert(RestaurantVisit(
                date: Date().addingTimeInterval(-86400 * 90),
                companion: "Partner",
                note: "Anniversary dinner - vegetable-focused menu was extraordinary",
                rating: 5,
                signatureDishes: ["Beetroot with Caviar", "Turnip and Radish Symphony", "Garden Vegetables", "Alain Passard's Tomato"],
                restaurant: arpege
            ))
        }
        
        // === RESTAURANT WISHLISTS ===
        let hongKongRestaurants = restaurantMap.values.filter { $0.city?.name == "Hong Kong" }
        let tokyoRestaurants = restaurantMap.values.filter { $0.city?.name == "Tokyo" }
        
        // Hong Kong restaurants wishlist
        if let forum = hongKongRestaurants.first(where: { $0.name.contains("Forum") && $0.michelinLevel == 3 }) {
            context.insert(RestaurantWishlist(
                restaurant: forum,
                note: "3-star Cantonese! Must try their signature dishes",
                priority: 1,
                signatureDishes: ["Barbecued Suckling Pig", "Crispy Chicken", "Steamed Fresh Grouper", "Abalone with Oyster Sauce"]
            ))
        }
        
        if let timHoWan = hongKongRestaurants.first(where: { $0.name.contains("Tim Ho Wan") }) {
            context.insert(RestaurantWishlist(
                restaurant: timHoWan,
                note: "Famous dim sum, affordable Michelin star",
                priority: 2,
                signatureDishes: ["Baked BBQ Pork Buns", "Steamed Egg Cake", "Pan Fried Turnip Cake", "Vermicelli Roll with Pig's Liver"]
            ))
        }
        
        // Tokyo restaurants wishlist
        if let sukiyabashi = tokyoRestaurants.first(where: { $0.name.contains("Sukiyabashi") }) {
            context.insert(RestaurantWishlist(
                restaurant: sukiyabashi,
                note: "Jiro's legendary sushi - bucket list!",
                priority: 1,
                signatureDishes: ["Omakase Nigiri Course", "Otoro", "Chu-toro", "Uni", "Kohada", "Anago"]
            ))
        }
        
        // === SAMPLE EVENTS ===
        let shanghaiNewYear = Event(
            name: "Shanghai New Year Fireworks",
            category: "Festival",
            city: "Shanghai",
            country: "China",
            note: "Annual spectacular display at the Bund"
        )
        context.insert(shanghaiNewYear)
        
        let tokyoCherry = Event(
            name: "Tokyo Cherry Blossom Festival",
            category: "Festival",
            city: "Tokyo",
            country: "Japan",
            note: "Hanami season in Ueno Park"
        )
        context.insert(tokyoCherry)
        
        // Event visit
        context.insert(EventVisit(
            date: Date().addingTimeInterval(-86400 * 365),
            note: "Incredible atmosphere, so crowded but worth it!",
            event: shanghaiNewYear
        ))
        
        // Event wishlist
        context.insert(EventWishlist(
            event: tokyoCherry,
            note: "Dream to see cherry blossoms in person",
            priority: 1
        ))
        
        print("✅ Added sample data:")
        print("   • 9+ city visits across 7 country visits (Shanghai x3, Beijing x3, Paris x1, plus multi-city trip)")
        print("   • 5+ transportation records (flights, trains, cars)")
        print("   • 3 city wishlists (Hong Kong, Tokyo, New York)")
        print("   • 2 country wishlists (Japan, USA)")
        print("   • ~5 restaurant visits")
        print("   • ~3 restaurant wishlists")
        print("   • 2 events with 1 visit and 1 wishlist")
    }
}

