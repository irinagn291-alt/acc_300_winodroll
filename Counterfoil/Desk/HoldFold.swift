import Foundation

/// Role: Desk. Closed algebraic fold Blank | Cooling | Released. A fourth case is a defect. Cooling-ness is this case, never a parallel bool.
enum HoldFold: String, Codable, Sendable, Equatable {
    case blank
    case cooling
    case released
}

/// Role: Desk. How a Released will-call left the rail. Cut is a fate, not a fourth fold case.
enum ClaimFate: String, Codable, Sendable, Equatable {
    case bought
    case dropped
    case cut
}

/// Role: Desk. Recoverable load outcome. Never crash on a corrupt snapshot.
enum DeskWarning: Equatable, Sendable {
    case recoveredFromBackup
    case startedEmpty
}

/// Role: Cut. Result of cutCover. Covered folds Cooling to Released. Short writes a ShortMark and keeps the ticket.
enum CutOutcome: Equatable, Sendable {
    case covered
    case short
}
