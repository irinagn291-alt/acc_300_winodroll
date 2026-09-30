import Foundation

/// Role: Desk. Four destinations as desk-locked sheets. Never a Game tab. ReviewScreen keys are not tabs.
enum DeskPane: String, Equatable, Sendable, CaseIterable {
    case desk
    case review
    case rules
    case settings
}

/// Role: Desk. Launch keys for live shots. today, log, and goals open three different screens. Extra keys settings and rehold.
enum ReviewHook: String, Equatable, Sendable {
    case today
    case log
    case goals
    case settings
    case rehold

    var pane: DeskPane {
        switch self {
        case .today, .rehold: .desk
        case .log: .review
        case .goals: .rules
        case .settings: .settings
        }
    }

    static func parse(_ raw: String) -> ReviewHook? {
        switch raw.lowercased() {
        case "today", "desk", "home": .today
        case "log", "review": .log
        case "goals", "rules": .goals
        case "settings": .settings
        case "rehold", "twist", "longerspan": .rehold
        default: nil
        }
    }
}

/// Role: Desk. Reads ProcessInfo `-ReviewScreen today|log|goals` once after onboarding. Extra cover slugs open those screens. No View.
enum DeskLaunch {
    static let flag = "-ReviewScreen"

    static func consume(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        onboardingComplete: Bool,
        consumed: inout Bool
    ) -> ReviewHook? {
        guard onboardingComplete, !consumed else { return nil }
        consumed = true
        guard let index = arguments.firstIndex(of: flag) else { return nil }
        let next = arguments.index(after: index)
        guard arguments.indices.contains(next) else { return nil }
        return ReviewHook.parse(arguments[next])
    }
}
