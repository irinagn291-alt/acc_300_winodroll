import Foundation

/// Role: Desk. Local-only product. Leftover search_api is unused. Filing types a retail code. No URLSession catalog client, no cgi/search.pl, no Open Food Facts.
enum DeskNet {
    static let userAgent = "Counterfoil/1.0 (iOS; +https://counterfoil-desk.pro)"
    static let contactURL = URL(string: "https://counterfoil-desk.pro/contact-us")
    static let catalogEnabled = false

    static func lookupRetailCode(_ code: String) -> String? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }
}
