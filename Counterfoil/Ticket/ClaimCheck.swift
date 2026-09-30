import Foundation

/// Role: Ticket. Stamped hold with computed hours and stampedAt. Remaining hours are not stored; they are computed hours minus elapsed, floored at zero.
struct ClaimCheck: Codable, Equatable, Sendable {
    var computedHours: Double
    var stampedAt: Date
    var stampedDayKey: Int

    func remainingInterval(at now: Date) -> TimeInterval {
        let span = computedHours * 3600
        let elapsed = now.timeIntervalSince(stampedAt)
        return max(0, span - elapsed)
    }

    func remainingHours(at now: Date) -> Double {
        remainingInterval(at: now) / 3600
    }
}
