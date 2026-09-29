import Foundation
import SwiftData

/// Handles data migrations when the schema changes
enum DataMigration {
    
    /// Update existing countries with Chinese names
    static func addChineseNamesToCountries(in container: ModelContainer) {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        
        // Fetch all countries
        let countryFetch = FetchDescriptor<Country>()
        guard let countries = try? context.fetch(countryFetch) else {
            print("⚠️ Migration: Could not fetch countries")
            return
        }
        
        print("🔄 Migration: Updating \(countries.count) countries with Chinese names...")
        
        var updatedCount = 0
        for country in countries {
            // Get the Chinese name from CountryDataProvider
            if let chineseName = CountryDataProvider.chineseNameForCountry(code: country.code) {
                if country.chineseName != chineseName {
                    country.chineseName = chineseName
                    updatedCount += 1
                }
            }
        }
        
        do {
            try context.save()
            print("✅ Migration: Updated \(updatedCount) countries with Chinese names")
        } catch {
            print("❌ Migration failed: \(error)")
        }
    }
    
    /// Update existing cities with Chinese names from ChineseCitiesDataProvider
    static func addChineseNamesToCities(in container: ModelContainer) {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        
        // Fetch all cities
        let cityFetch = FetchDescriptor<City>()
        guard let cities = try? context.fetch(cityFetch) else {
            print("⚠️ Migration: Could not fetch cities")
            return
        }
        
        print("🔄 Migration: Updating \(cities.count) cities with Chinese names...")
        
        // Get Chinese city data
        let chineseCityData = ChineseCitiesDataProvider.allChineseCities()
        
        // Build a dictionary that handles duplicate city names
        // For duplicates, we'll store multiple entries and match by country/province if available
        var chineseNameMap: [String: String] = [:]
        var duplicateCityNames: Set<String> = []
        
        // First pass: identify duplicates
        var seenNames = Set<String>()
        for cityData in chineseCityData {
            if seenNames.contains(cityData.name) {
                duplicateCityNames.insert(cityData.name)
            } else {
                seenNames.insert(cityData.name)
            }
        }
        
        // Second pass: build the map, only adding unique names
        for cityData in chineseCityData {
            if !duplicateCityNames.contains(cityData.name) {
                chineseNameMap[cityData.name] = cityData.chineseName
            }
        }
        
        // For duplicate names, create a more specific lookup by city name + country
        var specificLookup: [String: String] = [:]
        for cityData in chineseCityData where duplicateCityNames.contains(cityData.name) {
            let key = "\(cityData.name)_\(cityData.countryCode)"
            specificLookup[key] = cityData.chineseName
        }
        
        // Hardcoded Chinese names for international cities
        let internationalCityNames: [String: String] = [
            "New York": "纽约",
            "San Francisco": "旧金山",
            "Los Angeles": "洛杉矶",
            "Chicago": "芝加哥",
            "Paris": "巴黎",
            "Tokyo": "东京",
            "London": "伦敦",
            "Barcelona": "巴塞罗那",
            "Rome": "罗马",
            "Singapore": "新加坡"
        ]
        
        var updatedCount = 0
        for city in cities {
            var chineseName: String?
            
            // Try specific lookup first (for duplicate city names)
            if duplicateCityNames.contains(city.name), let country = city.country {
                let key = "\(city.name)_\(country.code)"
                chineseName = specificLookup[key]
            }
            
            // Try general lookup
            if chineseName == nil {
                chineseName = chineseNameMap[city.name]
            }
            
            // Fall back to international cities
            if chineseName == nil {
                chineseName = internationalCityNames[city.name]
            }
            
            if let chineseName = chineseName, city.chineseName != chineseName {
                city.chineseName = chineseName
                updatedCount += 1
            }
        }
        
        do {
            try context.save()
            print("✅ Migration: Updated \(updatedCount) cities with Chinese names")
        } catch {
            print("❌ Migration failed: \(error)")
        }
    }
    
    /// Update existing restaurants with Chinese names from MichelinDataProvider
    static func addChineseNamesToRestaurants(in container: ModelContainer) {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        
        // Fetch all restaurants
        let restaurantFetch = FetchDescriptor<MichelinRestaurant>()
        guard let restaurants = try? context.fetch(restaurantFetch) else {
            print("⚠️ Migration: Could not fetch restaurants")
            return
        }
        
        print("🔄 Migration: Updating \(restaurants.count) restaurants with Chinese names...")
        
        // Get restaurant data with Chinese names
        let restaurantData = MichelinDataProvider.sampleRestaurants()
        
        // Build a dictionary that handles duplicate restaurant names
        var chineseNameMap: [String: String] = [:]
        var duplicateRestaurantNames: Set<String> = []
        
        // First pass: identify duplicates
        var seenNames = Set<String>()
        for data in restaurantData where data.chineseName != nil {
            if seenNames.contains(data.name) {
                duplicateRestaurantNames.insert(data.name)
            } else {
                seenNames.insert(data.name)
            }
        }
        
        // Second pass: build the map, only adding unique names
        for data in restaurantData where data.chineseName != nil {
            if !duplicateRestaurantNames.contains(data.name) {
                chineseNameMap[data.name] = data.chineseName
            }
        }
        
        // For duplicate names, create a more specific lookup by restaurant name + city
        var specificLookup: [String: String] = [:]
        for data in restaurantData where data.chineseName != nil && duplicateRestaurantNames.contains(data.name) {
            let key = "\(data.name)_\(data.city)"
            specificLookup[key] = data.chineseName
        }
        
        var updatedCount = 0
        for restaurant in restaurants {
            var chineseName: String?
            
            // Try specific lookup first (for duplicate restaurant names)
            if duplicateRestaurantNames.contains(restaurant.name), let city = restaurant.city {
                let key = "\(restaurant.name)_\(city)"
                chineseName = specificLookup[key]
            }
            
            // Try general lookup
            if chineseName == nil {
                chineseName = chineseNameMap[restaurant.name]
            }
            
            if let chineseName = chineseName, restaurant.chineseName != chineseName {
                restaurant.chineseName = chineseName
                updatedCount += 1
            }
        }
        
        do {
            try context.save()
            print("✅ Migration: Updated \(updatedCount) restaurants with Chinese names")
        } catch {
            print("❌ Migration failed: \(error)")
        }
    }
    
    /// Update existing cities with province information from ChineseCitiesDataProvider
    static func addProvincesToCities(in container: ModelContainer) {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        
        // Fetch all cities
        let cityFetch = FetchDescriptor<City>()
        guard let cities = try? context.fetch(cityFetch) else {
            print("⚠️ Migration: Could not fetch cities")
            return
        }
        
        print("🔄 Migration: Updating \(cities.count) cities with province information...")
        
        // Get Chinese city data
        let chineseCityData = ChineseCitiesDataProvider.allChineseCities()
        
        // Build a lookup map by city name
        var cityDataMap: [String: ChineseCitiesDataProvider.ChinaCityData] = [:]
        for cityData in chineseCityData {
            cityDataMap[cityData.name] = cityData
        }
        
        var updatedCount = 0
        for city in cities {
            // Only update Chinese cities that don't have province info yet
            if city.isChina, city.province == nil {
                if let cityData = cityDataMap[city.name] {
                    city.province = cityData.province
                    city.provinceChinese = cityData.provinceChinese
                    updatedCount += 1
                }
            }
        }
        
        do {
            try context.save()
            print("✅ Migration: Updated \(updatedCount) cities with province information")
        } catch {
            print("❌ Migration failed: \(error)")
        }
    }
    
    /// Update existing cities with thumbnail URLs from ChineseCitiesDataProvider
    static func addThumbnailsToCities(in container: ModelContainer) async {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        
        // Fetch all cities
        let cityFetch = FetchDescriptor<City>()
        guard let cities = try? context.fetch(cityFetch) else {
            print("⚠️ Migration: Could not fetch cities")
            return
        }
        
        print("🔄 Migration: Updating \(cities.count) cities with thumbnail URLs...")
        
        // Get Chinese city data asynchronously
        let chineseCityData = await ChineseCitiesDataProvider.allChineseCitiesAsync()
        
        if chineseCityData.isEmpty {
            print("⚠️ Migration: No city data loaded from Google Drive - skipping thumbnail migration")
            return
        }
        
        // Build a lookup map by city name
        var cityDataMap: [String: ChineseCitiesDataProvider.ChinaCityData] = [:]
        for cityData in chineseCityData {
            cityDataMap[cityData.name] = cityData
        }
        
        var updatedCount = 0
        for city in cities {
            // Update cities that don't have thumbnail URLs yet
            if city.thumbnailURL == nil {
                if let cityData = cityDataMap[city.name], let thumbnailURL = cityData.thumbnailURL {
                    city.thumbnailURL = thumbnailURL
                    updatedCount += 1
                    print("   📸 Adding thumbnail to \(city.name): \(thumbnailURL)")
                }
            }
        }
        
        do {
            try context.save()
            print("✅ Migration: Updated \(updatedCount) cities with thumbnail URLs")
        } catch {
            print("❌ Migration failed: \(error)")
        }
    }
    
    /// Run all migrations
    static func runMigrations(in container: ModelContainer) async {
        print("🚀 Starting data migrations...")
        
        addChineseNamesToCountries(in: container)
        addChineseNamesToCities(in: container)
        addChineseNamesToRestaurants(in: container)
        addProvincesToCities(in: container)
        await addThumbnailsToCities(in: container)
        
        print("✅ All migrations completed!")
    }
}

// Make the helper function public so it can be used by DataMigration
extension CountryDataProvider {
    static func chineseNameForCountry(code: String) -> String? {
        switch code.uppercased() {
        // Major Asian countries
        case "CN": return "中国"
        case "JP": return "日本"
        case "KR": return "韩国"
        case "KP": return "朝鲜"
        case "TH": return "泰国"
        case "VN": return "越南"
        case "SG": return "新加坡"
        case "MY": return "马来西亚"
        case "ID": return "印度尼西亚"
        case "PH": return "菲律宾"
        case "IN": return "印度"
        case "PK": return "巴基斯坦"
        case "BD": return "孟加拉国"
        case "MM": return "缅甸"
        case "KH": return "柬埔寨"
        case "LA": return "老挝"
        case "NP": return "尼泊尔"
        case "LK": return "斯里兰卡"
        case "MN": return "蒙古"
        case "HK": return "香港"
        case "MO": return "澳门"
        case "TW": return "台湾"
        
        // Major Western countries
        case "US": return "美国"
        case "CA": return "加拿大"
        case "GB": return "英国"
        case "FR": return "法国"
        case "DE": return "德国"
        case "IT": return "意大利"
        case "ES": return "西班牙"
        case "PT": return "葡萄牙"
        case "NL": return "荷兰"
        case "BE": return "比利时"
        case "CH": return "瑞士"
        case "AT": return "奥地利"
        case "SE": return "瑞典"
        case "NO": return "挪威"
        case "DK": return "丹麦"
        case "FI": return "芬兰"
        case "IS": return "冰岛"
        case "IE": return "爱尔兰"
        case "GR": return "希腊"
        case "TR": return "土耳其"
        
        // Eastern Europe
        case "RU": return "俄罗斯"
        case "UA": return "乌克兰"
        case "PL": return "波兰"
        case "CZ": return "捷克"
        case "SK": return "斯洛伐克"
        case "HU": return "匈牙利"
        case "RO": return "罗马尼亚"
        case "BG": return "保加利亚"
        case "HR": return "克罗地亚"
        case "RS": return "塞尔维亚"
        case "SI": return "斯洛文尼亚"
        case "EE": return "爱沙尼亚"
        case "LV": return "拉脱维亚"
        case "LT": return "立陶宛"
        case "BY": return "白俄罗斯"
        
        // Middle East
        case "IL": return "以色列"
        case "SA": return "沙特阿拉伯"
        case "AE": return "阿联酋"
        case "IR": return "伊朗"
        case "IQ": return "伊拉克"
        case "EG": return "埃及"
        case "JO": return "约旦"
        case "LB": return "黎巴嫩"
        case "SY": return "叙利亚"
        case "KW": return "科威特"
        case "QA": return "卡塔尔"
        case "BH": return "巴林"
        case "OM": return "阿曼"
        case "YE": return "也门"
        
        // Americas
        case "MX": return "墨西哥"
        case "BR": return "巴西"
        case "AR": return "阿根廷"
        case "CL": return "智利"
        case "CO": return "哥伦比亚"
        case "PE": return "秘鲁"
        case "VE": return "委内瑞拉"
        case "EC": return "厄瓜多尔"
        case "CU": return "古巴"
        case "BO": return "玻利维亚"
        case "PY": return "巴拉圭"
        case "UY": return "乌拉圭"
        
        // Africa
        case "ZA": return "南非"
        case "NG": return "尼日利亚"
        case "KE": return "肯尼亚"
        case "ET": return "埃塞俄比亚"
        case "GH": return "加纳"
        case "TZ": return "坦桑尼亚"
        case "UG": return "乌干达"
        case "DZ": return "阿尔及利亚"
        case "MA": return "摩洛哥"
        case "TN": return "突尼斯"
        case "LY": return "利比亚"
        case "SD": return "苏丹"
        
        // Oceania
        case "AU": return "澳大利亚"
        case "NZ": return "新西兰"
        case "FJ": return "斐济"
        
        default: return nil
        }
    }
}
