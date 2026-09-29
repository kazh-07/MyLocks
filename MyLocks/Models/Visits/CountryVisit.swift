import Foundation
import SwiftData

@Model
final class CountryVisit {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String?
    var country: Country?

    init(date: Date, note: String? = nil, country: Country? = nil) {
        self.id = UUID()
        self.date = date
        self.note = note
        self.country = country
    }
}
