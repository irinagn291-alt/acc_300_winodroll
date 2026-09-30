import Foundation

/// Role: Desk. Local monthly impulse limit. Rules never talk to a store or a remote catalog.
struct DeskRule: Codable, Equatable, Sendable {
    var monthlyImpulseLimit: Double

    static let starter = DeskRule(monthlyImpulseLimit: 400)

    func validated() throws -> DeskRule {
        guard monthlyImpulseLimit.isFinite, monthlyImpulseLimit > 0 else { throw DeskFault.invalidLimit }
        return DeskRule(monthlyImpulseLimit: monthlyImpulseLimit)
    }
}
