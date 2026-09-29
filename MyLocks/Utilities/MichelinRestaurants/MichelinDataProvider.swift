import Foundation

/// Michelin restaurant data provider
/// This contains curated data for Michelin-starred and Michelin Guide restaurants worldwide
struct MichelinDataProvider {
    
    // Google Sheets CSV export URL
    // Original: https://docs.google.com/spreadsheets/d/1NWOWe6v9rgL4NZ0UCjJThxjU1hDehESDkfXqxUj1PTQ/edit?usp=sharing
    // CSV Export: https://docs.google.com/spreadsheets/d/SHEET_ID/export?format=csv
    private static let googleSheetsURL = "https://docs.google.com/spreadsheets/d/1NWOWe6v9rgL4NZ0UCjJThxjU1hDehESDkfXqxUj1PTQ/export?format=csv"
    
    struct RestaurantData: Codable {
        let name: String
        let chineseName: String?
        let city: String
        let countryCode: String
        let michelinLevel: Int // 0 = Guide, 1-3 = Stars
        let cuisine: String?
        let cuisineChinese: String?
        let latitude: Double?
        let longitude: Double?
        let thumbnailURL: String?
    }
    
    /// Load restaurant data asynchronously from Google Sheets
    static func loadRestaurantsAsync() async -> [RestaurantData] {
        // Try to fetch from Google Sheets first
        if let url = URL(string: googleSheetsURL) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let csvString = String(data: data, encoding: .utf8) {
                    let restaurants = parseCSV(csvString)
                    if !restaurants.isEmpty {
                        print("✅ Loaded \(restaurants.count) restaurants from Google Sheets")
                        return restaurants
                    }
                }
            } catch {
                print("⚠️ Failed to load from Google Sheets: \(error.localizedDescription)")
            }
        }
        
        return []
    }
    
    /// Parse CSV string into restaurant data
    private static func parseCSV(_ csvString: String) -> [RestaurantData] {
        let lines = csvString.components(separatedBy: .newlines)
        var restaurants: [RestaurantData] = []
        
        // Skip header row and empty lines
        for line in lines.dropFirst() where !line.isEmpty {
            let columns = parseCSVLine(line)
            
            // Ensure we have all required columns
            // Format: City,City_CN,GuideYear,Restaurant,Restaurant_CN,Stars,Cuisine,Cuisine_CN,Status,Announced,MichelinPage,Thumbnail_Michelin,Thumbnail_GoogleDrive
            guard columns.count >= 13 else { continue }
            
            let city = columns[0].trimmingCharacters(in: .whitespaces)
            let restaurant = columns[3].trimmingCharacters(in: .whitespaces)
            let restaurantCN = columns[4].trimmingCharacters(in: .whitespaces)
            let starsString = columns[5].trimmingCharacters(in: .whitespaces)
            let cuisine = columns[6].trimmingCharacters(in: .whitespaces)
            let cuisineCN = columns[7].trimmingCharacters(in: .whitespaces)
            let thumbnailGoogleDrive = columns[12].trimmingCharacters(in: .whitespaces)
            
            // Convert stars to Int (default to 0 for Bib Gourmand if parsing fails)
            let stars = Int(starsString) ?? 0
            
            // Map city to country code
            let countryCode = countryCodeForCity(city)
            
            // Convert Google Drive sharing link to direct image URL
            let imageURL = convertGoogleDriveURL(thumbnailGoogleDrive)
            
            let restaurantData = RestaurantData(
                name: restaurant,
                chineseName: restaurantCN.isEmpty ? nil : restaurantCN,
                city: city,
                countryCode: countryCode,
                michelinLevel: stars,
                cuisine: cuisine.isEmpty ? nil : cuisine,
                cuisineChinese: cuisineCN.isEmpty ? nil : cuisineCN,
                latitude: nil,
                longitude: nil,
                thumbnailURL: imageURL
            )
            
            restaurants.append(restaurantData)
        }
        
        return restaurants
    }
    
    /// Convert Google Drive sharing link to direct image URL
    private static func convertGoogleDriveURL(_ shareURL: String) -> String? {
        // Convert from: https://drive.google.com/file/d/FILE_ID/view
        // To: https://drive.google.com/uc?export=view&id=FILE_ID
        
        guard !shareURL.isEmpty else { return nil }
        
        if let range = shareURL.range(of: "/d/") {
            let afterD = shareURL[range.upperBound...]
            if let endRange = afterD.range(of: "/") {
                let fileID = String(afterD[..<endRange.lowerBound])
                return "https://drive.google.com/uc?export=view&id=\(fileID)"
            }
        }
        
        return shareURL.isEmpty ? nil : shareURL
    }
    
    /// Parse a CSV line handling quoted fields
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        // Add the last field
        fields.append(currentField)
        
        return fields
    }
    
    /// Map city name to country code based on the CSV data
    private static func countryCodeForCity(_ city: String) -> String {
        switch city {
        case "Beijing", "Shanghai", "Guangzhou", "Shenzhen", "Chengdu":
            return "CN"
        case "Hong Kong":
            return "HK"
        case "Macau":
            return "MO"
        default:
            return "CN" // Default to China for other cities
        }
    }
    
    /// Get sample restaurant data synchronously (for migrations and fallback)
    static func sampleRestaurants() -> [RestaurantData] {
        return [
            // USA - New York
            RestaurantData(name: "Eleven Madison Park", chineseName: nil, city: "New York", countryCode: "US", michelinLevel: 3, cuisine: "Contemporary", cuisineChinese: "当代菜", latitude: 40.7128, longitude: -74.0060, thumbnailURL: nil),
            RestaurantData(name: "Le Bernardin", chineseName: nil, city: "New York", countryCode: "US", michelinLevel: 3, cuisine: "French Seafood", cuisineChinese: "法国海鲜", latitude: 40.7128, longitude: -74.0060, thumbnailURL: nil),
            RestaurantData(name: "Per Se", chineseName: nil, city: "New York", countryCode: "US", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 40.7128, longitude: -74.0060, thumbnailURL: nil),
            RestaurantData(name: "Masa", chineseName: nil, city: "New York", countryCode: "US", michelinLevel: 3, cuisine: "Japanese", cuisineChinese: "日本菜", latitude: 40.7128, longitude: -74.0060, thumbnailURL: nil),
            RestaurantData(name: "Joe's Shanghai", chineseName: "乔家上海", city: "New York", countryCode: "US", michelinLevel: 0, cuisine: "Chinese", cuisineChinese: "中国菜", latitude: 40.7128, longitude: -74.0060, thumbnailURL: nil),
            
            // USA - San Francisco
            RestaurantData(name: "Benu", chineseName: nil, city: "San Francisco", countryCode: "US", michelinLevel: 3, cuisine: "Contemporary", cuisineChinese: "当代菜", latitude: 37.7749, longitude: -122.4194, thumbnailURL: nil),
            RestaurantData(name: "Quince", chineseName: nil, city: "San Francisco", countryCode: "US", michelinLevel: 3, cuisine: "Italian", cuisineChinese: "意大利菜", latitude: 37.7749, longitude: -122.4194, thumbnailURL: nil),
            RestaurantData(name: "Atelier Crenn", chineseName: nil, city: "San Francisco", countryCode: "US", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 37.7749, longitude: -122.4194, thumbnailURL: nil),
            
            // France - Paris
            RestaurantData(name: "Arpège", chineseName: nil, city: "Paris", countryCode: "FR", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 48.8566, longitude: 2.3522, thumbnailURL: nil),
            RestaurantData(name: "Guy Savoy", chineseName: nil, city: "Paris", countryCode: "FR", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 48.8566, longitude: 2.3522, thumbnailURL: nil),
            RestaurantData(name: "Le Cinq", chineseName: nil, city: "Paris", countryCode: "FR", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 48.8566, longitude: 2.3522, thumbnailURL: nil),
            RestaurantData(name: "Alain Ducasse au Plaza Athénée", chineseName: nil, city: "Paris", countryCode: "FR", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 48.8566, longitude: 2.3522, thumbnailURL: nil),
            
            // Japan - Tokyo
            RestaurantData(name: "Kanda", chineseName: "神田", city: "Tokyo", countryCode: "JP", michelinLevel: 3, cuisine: "Japanese", cuisineChinese: "日本菜", latitude: 35.6762, longitude: 139.6503, thumbnailURL: nil),
            RestaurantData(name: "Kohaku", chineseName: "琥珀", city: "Tokyo", countryCode: "JP", michelinLevel: 3, cuisine: "Japanese", cuisineChinese: "日本菜", latitude: 35.6762, longitude: 139.6503, thumbnailURL: nil),
            RestaurantData(name: "Quintessence", chineseName: nil, city: "Tokyo", countryCode: "JP", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 35.6762, longitude: 139.6503, thumbnailURL: nil),
            RestaurantData(name: "Sukiyabashi Jiro", chineseName: "数寄屋桥次郎", city: "Tokyo", countryCode: "JP", michelinLevel: 3, cuisine: "Sushi", cuisineChinese: "寿司", latitude: 35.6762, longitude: 139.6503, thumbnailURL: nil),
            
            // UK - London
            RestaurantData(name: "Restaurant Gordon Ramsay", chineseName: nil, city: "London", countryCode: "GB", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 51.5074, longitude: -0.1278, thumbnailURL: nil),
            RestaurantData(name: "Alain Ducasse at The Dorchester", chineseName: nil, city: "London", countryCode: "GB", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 51.5074, longitude: -0.1278, thumbnailURL: nil),
            RestaurantData(name: "The Araki", chineseName: "荒木", city: "London", countryCode: "GB", michelinLevel: 3, cuisine: "Sushi", cuisineChinese: "寿司", latitude: 51.5074, longitude: -0.1278, thumbnailURL: nil),
            
            // Spain - Barcelona
            RestaurantData(name: "Lasarte", chineseName: nil, city: "Barcelona", countryCode: "ES", michelinLevel: 3, cuisine: "Contemporary", cuisineChinese: "当代菜", latitude: 41.3851, longitude: 2.1734, thumbnailURL: nil),
            RestaurantData(name: "Moments", chineseName: nil, city: "Barcelona", countryCode: "ES", michelinLevel: 2, cuisine: "Catalan", cuisineChinese: "加泰罗尼亚菜", latitude: 41.3851, longitude: 2.1734, thumbnailURL: nil),
            
            // Italy - Rome
            RestaurantData(name: "La Pergola", chineseName: nil, city: "Rome", countryCode: "IT", michelinLevel: 3, cuisine: "Italian", cuisineChinese: "意大利菜", latitude: 41.9028, longitude: 12.4964, thumbnailURL: nil),
            
            // Germany - Berlin
            RestaurantData(name: "Tim Raue", chineseName: nil, city: "Berlin", countryCode: "DE", michelinLevel: 2, cuisine: "Asian Fusion", cuisineChinese: "亚洲融合菜", latitude: 52.5200, longitude: 13.4050, thumbnailURL: nil),
            
            // Singapore
            RestaurantData(name: "Les Amis", chineseName: nil, city: "Singapore", countryCode: "SG", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 1.3521, longitude: 103.8198, thumbnailURL: nil),
            RestaurantData(name: "Odette", chineseName: nil, city: "Singapore", countryCode: "SG", michelinLevel: 3, cuisine: "French", cuisineChinese: "法国菜", latitude: 1.3521, longitude: 103.8198, thumbnailURL: nil),
            RestaurantData(name: "Hawker Chan", chineseName: "了凡香港油鸡饭面", city: "Singapore", countryCode: "SG", michelinLevel: 1, cuisine: "Chinese", cuisineChinese: "中国菜", latitude: 1.3521, longitude: 103.8198, thumbnailURL: nil),
        ]
    }
}
