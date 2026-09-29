import Foundation
import SwiftData

@Model
final class EventVisit {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String?
    var event: Event?

    init(date: Date, note: String? = nil, event: Event? = nil) {
        self.id = UUID()
        self.date = date
        self.note = note
        self.event = event
    }
}
