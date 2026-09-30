import Foundation

/// Role: Desk. In-memory fold over will-calls. Stamp writes a ticket and folds Blank to Cooling. Cut writes a CoverMark or ShortMark. Empty desk writes Blank. Views call stampWant and cutCover.
struct Desk: Equatable, Sendable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var wants: [WillCall]
    var coverMarks: [CoverMark]
    var shortMarks: [ShortMark]
    var rules: DeskRule
    var faceID: UUID?

    static let currentSchema = 1

    static let empty = Desk(
        schemaVersion: currentSchema,
        onboardingComplete: false,
        wants: [],
        coverMarks: [],
        shortMarks: [],
        rules: .starter,
        faceID: nil
    )

    var fold: HoldFold {
        guard let face = faceWant else { return .blank }
        return face.hold
    }

    var faceWant: WillCall? {
        guard let faceID else { return nil }
        return want(faceID)
    }

    var coolingWants: [WillCall] {
        wants.filter { $0.hold == .cooling }
    }

    var releasedWants: [WillCall] {
        wants.filter { $0.hold == .released && $0.fate != .cut }
    }

    var cutWants: [WillCall] {
        wants.filter { $0.hold == .released && $0.fate == .cut }
    }

    var blankWants: [WillCall] {
        wants.filter { $0.hold == .blank }
    }

    var canStamp: Bool {
        wants.contains(where: \.isStampable)
    }

    func want(_ id: UUID) -> WillCall? {
        wants.first { $0.id == id }
    }

    func remainingHours(at now: Date) -> Double {
        faceWant?.remainingHours(at: now) ?? 0
    }

    func coveringIDs(at now: Date) -> [UUID] {
        guard let face = faceWant, face.hold == .cooling else { return [] }
        let need = face.remainingInterval(at: now)
        return coolingWants
            .filter { $0.id != face.id && $0.remainingInterval(at: now) >= need }
            .map(\.id)
    }

    func canCut(at now: Date) -> Bool {
        fold == .cooling && !coveringIDs(at: now).isEmpty
    }

    func canRelease(at now: Date) -> Bool {
        guard fold == .cooling else { return false }
        return remainingHours(at: now) <= 0
    }

    mutating func fileWant(_ draft: StampDraft, id: UUID = UUID(), now: Date, calendar: Calendar) throws -> UUID {
        let clean = try draft.validated()
        let row = WillCall(
            id: id,
            name: clean.name,
            price: clean.price,
            priority: clean.priority,
            necessity: clean.necessity,
            discretion: clean.discretion,
            retailCode: clean.retailCode,
            hold: .blank,
            ticket: nil,
            fate: nil,
            filedAt: now,
            filedDayKey: DeskDay.key(now, calendar: calendar)
        )
        wants.append(row)
        return row.id
    }

    mutating func stampWant(_ id: UUID, now: Date, calendar: Calendar) throws {
        guard let index = wants.firstIndex(where: { $0.id == id }) else { throw DeskFault.wantUnknown }
        guard wants[index].hold != .released else { throw DeskFault.stampReleased }
        let hours = RailHours.hours(
            price: wants[index].price,
            monthlyLimit: rules.monthlyImpulseLimit,
            priority: wants[index].priority,
            necessity: wants[index].necessity,
            discretion: wants[index].discretion
        )
        if let match = coolingIndexSharingCode(with: wants[index]) {
            rehold(at: match, freshHours: hours)
            faceID = wants[match].id
            return
        }
        if wants[index].hold == .cooling, let ticket = wants[index].ticket {
            wants[index].ticket = ClaimCheck(
                computedHours: max(ticket.computedHours, hours),
                stampedAt: ticket.stampedAt,
                stampedDayKey: ticket.stampedDayKey
            )
            faceID = wants[index].id
            return
        }
        wants[index].hold = .cooling
        wants[index].fate = nil
        wants[index].ticket = ClaimCheck(
            computedHours: hours,
            stampedAt: now,
            stampedDayKey: DeskDay.key(now, calendar: calendar)
        )
        faceID = wants[index].id
    }

    mutating func cutCover(sacrificing coverID: UUID, now: Date, calendar: Calendar) throws -> CutOutcome {
        guard fold == .cooling, let face = faceWant, face.hold == .cooling else {
            throw DeskFault.cutOnBlank
        }
        guard coverID != face.id else { throw DeskFault.coverIsFace }
        guard let coverIndex = wants.firstIndex(where: { $0.id == coverID }) else {
            throw DeskFault.coverUnknown
        }
        guard wants[coverIndex].hold == .cooling else { throw DeskFault.coverNotCooling }
        let needed = face.remainingHours(at: now)
        let offered = wants[coverIndex].remainingHours(at: now)
        let day = DeskDay.key(now, calendar: calendar)
        if offered + 0.000_001 < needed {
            shortMarks.append(
                ShortMark(
                    id: UUID(),
                    wantID: face.id,
                    offeredWantID: coverID,
                    neededHours: needed,
                    offeredHours: offered,
                    dayKey: day,
                    markedAt: now
                )
            )
            return .short
        }
        wants[coverIndex].hold = .released
        wants[coverIndex].fate = .cut
        if let faceIndex = wants.firstIndex(where: { $0.id == face.id }) {
            wants[faceIndex].hold = .released
            wants[faceIndex].fate = .bought
        }
        coverMarks.append(
            CoverMark(
                id: UUID(),
                releasedWantID: face.id,
                sacrificedWantID: coverID,
                coveredHours: offered,
                dayKey: day,
                markedAt: now
            )
        )
        advanceFace(leaving: face.id)
        return .covered
    }

    mutating func releaseFace(fate: ClaimFate, now: Date, calendar: Calendar) throws {
        _ = calendar
        guard fold == .cooling, let face = faceWant else { throw DeskFault.cutOnBlank }
        guard fate == .bought || fate == .dropped else { throw DeskFault.fateNotRelease }
        guard remainingHours(at: now) <= 0 else { throw DeskFault.railStillRunning }
        if let index = wants.firstIndex(where: { $0.id == face.id }) {
            wants[index].hold = .released
            wants[index].fate = fate
        }
        advanceFace(leaving: face.id)
    }

    mutating func saveLimit(_ monthlyImpulseLimit: Double) throws {
        rules = try DeskRule(monthlyImpulseLimit: monthlyImpulseLimit).validated()
    }

    mutating func setOnboardingComplete(_ flag: Bool) {
        onboardingComplete = flag
    }

    mutating func resetAll() {
        self = .empty
    }

    private mutating func rehold(at index: Int, freshHours: Double) {
        guard let ticket = wants[index].ticket else { return }
        wants[index].ticket = ClaimCheck(
            computedHours: max(ticket.computedHours, freshHours),
            stampedAt: ticket.stampedAt,
            stampedDayKey: ticket.stampedDayKey
        )
    }

    private func coolingIndexSharingCode(with draft: WillCall) -> Int? {
        guard let code = draft.normalizedCode, !code.isEmpty else { return nil }
        return wants.firstIndex {
            $0.id != draft.id
                && $0.hold == .cooling
                && $0.normalizedCode == code
        }
    }

    private mutating func advanceFace(leaving usedID: UUID) {
        faceID = coolingWants.first { $0.id != usedID }?.id
    }
}
