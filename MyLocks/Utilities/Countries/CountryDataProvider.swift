import Foundation

/// Provides comprehensive country data using iOS built-in APIs
struct CountryDataProvider {
    
    struct CountryData {
        let code: String
        let name: String
        let chineseName: String?
        let nativeName: String?
        let flagEmoji: String
        let continent: String
    }
    
    /// Generate flag emoji from country code
    static func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let flagScalar = UnicodeScalar(base + scalar.value) {
                emoji.append(String(flagScalar))
            }
        }
        return emoji
    }
    
    /// Get all available countries with their metadata
    static func allCountries() -> [CountryData] {
        var countries: [CountryData] = []
        
        // Get all available region codes from iOS
        for identifier in Locale.availableIdentifiers {
            let locale = Locale(identifier: identifier)
            
            // Get the region (country) from this locale
            if let regionCode = locale.region?.identifier,
               let countryName = Locale.current.localizedString(forRegionCode: regionCode) {
                
                // Skip if we already have this country
                if countries.contains(where: { $0.code == regionCode }) {
                    continue
                }
                
                // Get native name
                let nativeLocale = Locale(identifier: identifier)
                let nativeName = nativeLocale.localizedString(forRegionCode: regionCode)
                
                // Get continent
                let continent = continentForCountry(code: regionCode)
                
                // Get Chinese name using iOS built-in localization
                let chineseLocale = Locale(identifier: "zh_CN")
                let chineseName = chineseLocale.localizedString(forRegionCode: regionCode)
                
                countries.append(CountryData(
                    code: regionCode,
                    name: countryName,
                    chineseName: chineseName,
                    nativeName: nativeName,
                    flagEmoji: flagEmoji(for: regionCode),
                    continent: continent
                ))
            }
        }
        
        // Sort by name
        return countries.sorted { $0.name < $1.name }
    }

    /// Map country codes to continents
    /// This is a comprehensive mapping since iOS doesn't provide this natively
    private static func continentForCountry(code: String) -> String {
        switch code.uppercased() {
        // Asia
        case "AF", "AM", "AZ", "BH", "BD", "BT", "BN", "KH", "CN", "CY", "GE", "HK", "IN", 
             "ID", "IR", "IQ", "IL", "JP", "JO", "KZ", "KW", "KG", "LA", "LB", "MO", "MY",
             "MV", "MN", "MM", "NP", "KP", "OM", "PK", "PS", "PH", "QA", "SA", "SG", "KR",
             "LK", "SY", "TW", "TJ", "TH", "TL", "TR", "TM", "AE", "UZ", "VN", "YE":
            return "Asia"
            
        // Europe
        case "AL", "AD", "AT", "BY", "BE", "BA", "BG", "HR", "CZ", "DK", "EE", "FI", "FR",
             "DE", "GR", "HU", "IS", "IE", "IT", "XK", "LV", "LI", "LT", "LU", "MT", "MD",
             "MC", "ME", "NL", "MK", "NO", "PL", "PT", "RO", "RU", "SM", "RS", "SK", "SI",
             "ES", "SE", "CH", "UA", "GB", "VA", "AX", "GG", "JE", "IM", "SJ", "FO", "GI":
            return "Europe"
            
        // North America
        case "AG", "BS", "BB", "BZ", "CA", "CR", "CU", "DM", "DO", "SV", "GD", "GT", "HT",
             "HN", "JM", "MX", "NI", "PA", "KN", "LC", "VC", "TT", "US", "AI", "AW", "BM",
             "BQ", "VG", "KY", "CW", "GL", "GP", "MQ", "MS", "PM", "PR", "BL", "MF", "SX",
             "TC", "VI":
            return "North America"
            
        // South America
        case "AR", "BO", "BR", "CL", "CO", "EC", "GY", "PY", "PE", "SR", "UY", "VE", "FK",
             "GF", "BV":
            return "South America"
            
        // Africa
        case "DZ", "AO", "BJ", "BW", "BF", "BI", "CM", "CV", "CF", "TD", "KM", "CG", "CD",
             "DJ", "EG", "GQ", "ER", "ET", "GA", "GM", "GH", "GN", "GW", "CI", "KE", "LS",
             "LR", "LY", "MG", "MW", "ML", "MR", "MU", "YT", "MA", "MZ", "NA", "NE", "NG",
             "RE", "RW", "ST", "SN", "SC", "SL", "SO", "ZA", "SS", "SD", "SZ", "TZ", "TG",
             "TN", "UG", "EH", "ZM", "ZW", "SH", "IO":
            return "Africa"
            
        // Oceania
        case "AS", "AU", "CK", "FJ", "PF", "GU", "KI", "MH", "FM", "NR", "NC", "NZ", "NU",
             "NF", "MP", "PW", "PG", "PN", "WS", "SB", "TK", "TO", "TV", "UM", "VU", "WF",
             "CC", "HM", "TF":
            return "Oceania"
            
        // Antarctica
        case "AQ", "GS":
            return "Antarctica"
            
        default:
            return "Unknown"
        }
    }
}
