import Foundation

/// Role: Desk. A priced want filed at the will-call window. Hold is Blank, Cooling, or Released. Remaining hours are derived from the ticket.
struct WillCall: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var name: String
    var price: Double
    var priority: Double
    var necessity: Double
    var discretion: Double
    var retailCode: String?
    var hold: HoldFold
    var ticket: ClaimCheck?
    var fate: ClaimFate?
    var filedAt: Date
    var filedDayKey: Int

    var normalizedCode: String? {
        retailCode?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func remainingInterval(at now: Date) -> TimeInterval {
        guard hold == .cooling, let ticket else { return 0 }
        return ticket.remainingInterval(at: now)
    }

    func remainingHours(at now: Date) -> Double {
        remainingInterval(at: now) / 3600
    }

    var isStampable: Bool {
        hold != .released
    }
}
