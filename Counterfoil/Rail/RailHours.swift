import Foundation

/// Role: Rail. Family hours from price versus monthly limit. hours = base × priority × (1.5 − nec/100) × (2 − disc/100). Clamp 6…720.
enum RailHours {
    static let floorHours: Double = 6
    static let ceilingHours: Double = 720
    static let monthHours: Double = 720

    static func hours(
        price: Double,
        monthlyLimit: Double,
        priority: Double,
        necessity: Double,
        discretion: Double
    ) -> Double {
        let limit = max(monthlyLimit, Double.leastNonzeroMagnitude)
        let base = monthHours * (price / limit)
        let nec = min(max(necessity, 0), 100)
        let disc = min(max(discretion, 0), 100)
        let hours = base * priority * (1.5 - nec / 100) * (2 - disc / 100)
        guard hours.isFinite else { return floorHours }
        return min(max(hours, floorHours), ceilingHours)
    }
}
