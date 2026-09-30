import Foundation

/// Role: Desk. Sheets over the locked hold ticket. ReviewScreen keys map here. Not a tab bar.
enum ClaimSheet: String, Identifiable, Equatable, Sendable {
    case review
    case rules
    case settings
    case stamp
    case cut
    case rehold

    var id: String { rawValue }

    static func from(pane: DeskPane) -> ClaimSheet? {
        switch pane {
        case .desk: nil
        case .review: .review
        case .rules: .rules
        case .settings: .settings
        }
    }

    static func from(hook: ReviewHook) -> ClaimSheet? {
        switch hook {
        case .today: nil
        case .log: .review
        case .goals: .rules
        case .settings: .settings
        case .rehold: .rehold
        }
    }
}
