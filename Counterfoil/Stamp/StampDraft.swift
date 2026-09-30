import Foundation

/// Role: Stamp. Filing a priced want: name, price, priority, necessity, discretion, optional typed retail code. No camera, no catalog fetch.
struct StampDraft: Equatable, Sendable {
    var name: String
    var price: Double
    var priority: Double
    var necessity: Double
    var discretion: Double
    var retailCode: String?

    func validated() throws -> StampDraft {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DeskFault.emptyName }
        guard price.isFinite, price > 0 else { throw DeskFault.invalidPrice }
        guard priority.isFinite, priority > 0 else { throw DeskFault.invalidPriority }
        guard necessity.isFinite, necessity >= 0, necessity <= 100 else { throw DeskFault.invalidNecessity }
        guard discretion.isFinite, discretion >= 0, discretion <= 100 else { throw DeskFault.invalidDiscretion }
        let code = retailCode?.trimmingCharacters(in: .whitespacesAndNewlines)
        return StampDraft(
            name: trimmed,
            price: price,
            priority: priority,
            necessity: necessity,
            discretion: discretion,
            retailCode: (code?.isEmpty == false) ? code : nil
        )
    }
}
