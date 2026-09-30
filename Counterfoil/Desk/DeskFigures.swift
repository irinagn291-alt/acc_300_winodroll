import Foundation

/// Role: Desk. Locale numbers for remaining hours, price, and the monthly limit. Round only at display.
enum DeskFigures {
    static func hours(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "none"
    }

    static func money(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "none"
    }

    static func count(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "none"
    }

    static func ratio(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "none"
    }

    static func parseDecimal(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        guard let number = formatter.number(from: trimmed)?.doubleValue, number.isFinite else {
            return nil
        }
        return number
    }

    static func parsePositive(_ raw: String) -> Double? {
        guard let value = parseDecimal(raw), value > 0 else { return nil }
        return value
    }

    static func parseClosed(_ raw: String, min: Double, max: Double) -> Double? {
        guard let value = parseDecimal(raw), value >= min, value <= max else { return nil }
        return value
    }
}
