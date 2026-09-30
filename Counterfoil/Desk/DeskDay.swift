import Foundation

/// Role: Desk. Day keys as Int YYYYMMDD from Calendar.current.startOfDay in the user's zone.
enum DeskDay {
    static func key(_ date: Date, calendar: Calendar) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 1970
        let month = parts.month ?? 1
        let day = parts.day ?? 1
        return year * 10_000 + month * 100 + day
    }
}
