import Foundation
import SwiftUI

/// Represents the status of a place, restaurant, or event
enum WishlistStatus: String, Codable, CaseIterable {
    case notVisited = "Not Visited"
    case wishlisted = "Wishlisted"
    case visited = "Visited"
    
    var icon: String {
        switch self {
        case .notVisited:
            return "circle"
        case .wishlisted:
            return "heart.fill"
        case .visited:
            return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .notVisited:
            return .gray
        case .wishlisted:
            return .pink
        case .visited:
            return .green
        }
    }
    
    var displayText: String {
        return self.rawValue
    }
}
