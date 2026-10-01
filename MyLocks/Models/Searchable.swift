import Foundation

// MARK: - Searchable Protocol

protocol Searchable {
    func matches(searchText: String, language: String) -> Bool
}

// MARK: - Array Extension for Searchable

extension Array where Element: Searchable {
    func filtered(by searchText: String, language: String) -> [Element] {
        guard !searchText.isEmpty else { return self }
        return filter { $0.matches(searchText: searchText, language: language) }
    }
}

// MARK: - City Searchable Conformance

extension City: Searchable {
    func matches(searchText: String, language: String) -> Bool {
        let search = searchText.lowercased()
        
        // Search in English name
        if name.lowercased().contains(search) {
            return true
        }
        
        // Search in Chinese name
        if let chineseName = chineseName, chineseName.lowercased().contains(search) {
            return true
        }
        
        // Search in country name
        if let countryName = country?.localizedName(language: language), countryName.lowercased().contains(search) {
            return true
        }
        
        // Search in province
        if let province = localizedProvince(language: language), province.lowercased().contains(search) {
            return true
        }
        
        return false
    }
}

// MARK: - Country Searchable Conformance

extension Country: Searchable {
    func matches(searchText: String, language: String) -> Bool {
        let search = searchText.lowercased()
        
        // Search in English name
        if name.lowercased().contains(search) {
            return true
        }
        
        // Search in Chinese name
        if let chineseName = chineseName, chineseName.lowercased().contains(search) {
            return true
        }
        
        // Search in native name
        if let nativeName = nativeName, nativeName.lowercased().contains(search) {
            return true
        }
        
        // Search in country code
        if code.lowercased().contains(search) {
            return true
        }
        
        // Search in continent
        if let continent = continent, continent.lowercased().contains(search) {
            return true
        }
        
        return false
    }
}

// MARK: - MichelinRestaurant Searchable Conformance

extension MichelinRestaurant: Searchable {
    func matches(searchText: String, language: String) -> Bool {
        let search = searchText.lowercased()
        
        // Search in restaurant name
        if name.lowercased().contains(search) {
            return true
        }
        
        // Search in Chinese name
        if let chineseName = chineseName, chineseName.lowercased().contains(search) {
            return true
        }
        
        // Search in city name
        if let cityName = city?.localizedName(language: language), cityName.lowercased().contains(search) {
            return true
        }
        
        // Search in country name
        if let countryName = country?.localizedName(language: language), countryName.lowercased().contains(search) {
            return true
        }
        
        // Search in cuisine
        if let cuisine = localizedCuisine(language: language), cuisine.lowercased().contains(search) {
            return true
        }
        
        return false
    }
}
