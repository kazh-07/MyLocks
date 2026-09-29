import Foundation
import SwiftData

@Model
final class EventWishlist {
    @Attribute(.unique) var id: UUID
    var addedAt: Date
    var note: String?
    var priority: Int? // 1 = high, 2 = medium, 3 = low
    
    var event: Event?
    
    init(
        event: Event,
        note: String? = nil,
        priority: Int? = nil
    ) {
        self.id = UUID()
        self.event = event
        self.addedAt = Date()
        self.note = note
        self.priority = priority
    }
}
