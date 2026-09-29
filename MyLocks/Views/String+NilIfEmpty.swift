import Foundation

extension Optional where Wrapped == String {
    /// Returns nil if the string is nil, empty, or only whitespace/newlines.
    var nilIfEmptyOrWhitespace: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines),
              value.isEmpty == false else {
            return nil
        }
        return value
    }
}
