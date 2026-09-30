import Foundation

/// Role: ShortMark. Written when the offered cover remaining hours are short of this rail. The ticket stays Cooling.
struct ShortMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var wantID: UUID
    var offeredWantID: UUID
    var neededHours: Double
    var offeredHours: Double
    var dayKey: Int
    var markedAt: Date
}
