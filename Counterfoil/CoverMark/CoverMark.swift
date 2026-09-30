import Foundation

/// Role: CoverMark. Written when a sacrificed cooling ticket remaining hours cover this rail. The sacrificed want is dropped. This want folds Cooling to Released as bought.
struct CoverMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var releasedWantID: UUID
    var sacrificedWantID: UUID
    var coveredHours: Double
    var dayKey: Int
    var markedAt: Date
}
