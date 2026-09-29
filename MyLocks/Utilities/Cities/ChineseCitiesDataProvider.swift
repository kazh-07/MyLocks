import Foundation

/// Provides comprehensive Chinese city data with tiers and provinces
struct ChineseCitiesDataProvider {
    
    // Google Drive direct download URL
    // Original share link: https://drive.google.com/file/d/1oZpojO6AV9jyT0E6MQPiKRTGUm5b-5jC/view?usp=sharing
    // Direct download format: https://drive.google.com/uc?export=download&id=FILE_ID
    private static let googleDriveURL = "https://drive.google.com/uc?export=download&id=1oZpojO6AV9jyT0E6MQPiKRTGUm5b-5jC"
    
    struct ChinaCityData: Codable {
        let name: String
        let chineseName: String
        let tier: Int? // 1, 2, 3, or nil for HK/Macau/Taiwan
        let province: String
        let provinceChinese: String
        let countryCode: String // CN, HK, MO, or TW
        let thumbnailURL: String? // Direct URL to city thumbnail image
    }
    
    /// Load all Chinese cities asynchronously from Google Drive
    static func allChineseCitiesAsync() async -> [ChinaCityData] {
        // Try to fetch from Google Drive first
        if let url = URL(string: googleDriveURL) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let csvString = String(data: data, encoding: .utf8) {
                    let cities = parseCSV(csvString)
                    if !cities.isEmpty {
                        print("✅ Loaded \(cities.count) Chinese cities from Google Drive")
                        return cities
                    }
                }
            } catch {
                print("⚠️ Failed to load Chinese cities from Google Drive: \(error.localizedDescription)")
            }
        }
        
        // Return empty array if fetch fails
        print("⚠️ Unable to load Chinese cities data")
        return []
    }
    
    /// Load all Chinese cities synchronously (blocking)
    /// Note: This blocks the current thread. Prefer `allChineseCitiesAsync()` when possible.
    static func allChineseCities() -> [ChinaCityData] {
        guard let url = URL(string: googleDriveURL) else {
            print("⚠️ Invalid Google Drive URL")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            if let csvString = String(data: data, encoding: .utf8) {
                let cities = parseCSV(csvString)
                if !cities.isEmpty {
                    print("✅ Loaded \(cities.count) Chinese cities from Google Drive (sync)")
                    return cities
                }
            }
        } catch {
            print("⚠️ Failed to load Chinese cities synchronously: \(error.localizedDescription)")
        }
        
        return []
    }
    
    /// Parse CSV string into city data
    private static func parseCSV(_ csvString: String) -> [ChinaCityData] {
        let lines = csvString.components(separatedBy: .newlines)
        var cities: [ChinaCityData] = []
        
        print("📋 Parsing CSV with \(lines.count) lines")
        
        // Debug: Print the header line
        if !lines.isEmpty {
            print("   Header: \(lines[0])")
        }
        
        // Skip header row and empty lines
        for (index, line) in lines.dropFirst().enumerated() where !line.isEmpty {
            let columns = parseCSVLine(line)
            
            // Debug: Print first few rows to understand structure
            if index < 3 {
                print("   Row \(index): \(columns.count) columns")
                for (colIndex, col) in columns.enumerated() {
                    print("      [\(colIndex)]: '\(col.prefix(50))'")
                }
            }
            
            // Ensure we have at least the required columns
            // Expected format: Name, ChineseName, Tier, Province, ProvinceChinese, CountryCode, [ThumbnailLink]
            guard columns.count >= 6 else {
                if index < 3 {
                    print("   ⚠️ Skipping row \(index): only \(columns.count) columns")
                }
                continue
            }
            
            let name = columns[0].trimmingCharacters(in: .whitespaces)
            let chineseName = columns[1].trimmingCharacters(in: .whitespaces)
            let tierString = columns[2].trimmingCharacters(in: .whitespaces)
            let province = columns[3].trimmingCharacters(in: .whitespaces)
            let provinceChinese = columns[4].trimmingCharacters(in: .whitespaces)
            let countryCode = columns[5].trimmingCharacters(in: .whitespaces)
            let thumbnailLink = columns[8].trimmingCharacters(in: .whitespaces)
            let thumbnailURL = convertGoogleDriveURL(thumbnailLink)
            
            // Debug: Log thumbnail processing for first few cities
            if index < 3 {
                print("   🖼️ \(name):")
                print("      Raw link: '\(thumbnailLink)'")
                print("      Converted URL: '\(thumbnailURL ?? "nil")'")
            }
            
            // Convert tier string to Int? (empty string becomes nil)
            let tier: Int? = tierString.isEmpty ? nil : Int(tierString)
            
            let city = ChinaCityData(
                name: name,
                chineseName: chineseName,
                tier: tier,
                province: province,
                provinceChinese: provinceChinese,
                countryCode: countryCode,
                thumbnailURL: thumbnailURL
            )
            
            cities.append(city)
        }
        
        // Count cities with thumbnails
        let citiesWithThumbnails = cities.filter { $0.thumbnailURL != nil }.count
        print("📊 Parsed \(cities.count) cities, \(citiesWithThumbnails) have thumbnail URLs")
        
        return cities
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
    
    /// Convert Google Drive sharing link to direct image URL
    private static func convertGoogleDriveURL(_ shareURL: String) -> String? {
        // Convert from: https://drive.google.com/file/d/FILE_ID/view
        // To: https://drive.google.com/uc?export=view&id=FILE_ID
        
        guard !shareURL.isEmpty else { return nil }
        
        // Skip known non-image URLs (like lonelyplanet.com)
        let invalidDomains = ["lonelyplanet.com", "wikipedia.org", "tripadvisor.com"]
        if invalidDomains.contains(where: { shareURL.lowercased().contains($0) }) {
            print("⚠️ Skipping non-image URL: \(shareURL)")
            return nil
        }
        
        if let range = shareURL.range(of: "/d/") {
            let afterD = shareURL[range.upperBound...]
            if let endRange = afterD.range(of: "/") {
                let fileID = String(afterD[..<endRange.lowerBound])
                return "https://drive.google.com/uc?export=view&id=\(fileID)"
            }
        }
        
        // Only return URL if it appears to be a valid image URL
        // Check for common image file extensions or known image hosting domains
        let validExtensions = [".jpg", ".jpeg", ".png", ".gif", ".webp"]
        let validDomains = ["drive.google.com", "imgur.com", "cloudinary.com"]
        
        let isValidExtension = validExtensions.contains { shareURL.lowercased().hasSuffix($0) }
        let isValidDomain = validDomains.contains { shareURL.lowercased().contains($0) }
        
        if isValidExtension || isValidDomain {
            return shareURL
        }
        
        print("⚠️ URL doesn't appear to be a direct image link: \(shareURL)")
        return nil
    }
    
    /// Get cities by tier
    static func cities(tier: Int) -> [ChinaCityData] {
        return allChineseCities().filter { $0.tier == tier }
    }
    
    /// Get cities by province
    static func cities(inProvince province: String) -> [ChinaCityData] {
        return allChineseCities().filter { $0.province == province }
    }
    
    /// Get all unique provinces
    static func allProvinces() -> [(name: String, chineseName: String)] {
        let cities = allChineseCities()
        var seenProvinces = Set<String>()
        var uniqueProvinces: [(name: String, chineseName: String)] = []
        
        for city in cities {
            if !seenProvinces.contains(city.province) {
                seenProvinces.insert(city.province)
                uniqueProvinces.append((name: city.province, chineseName: city.provinceChinese))
            }
        }
        
        return uniqueProvinces.sorted { $0.name < $1.name }
    }
}
