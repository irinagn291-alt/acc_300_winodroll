import Foundation

/// Role: Cut. Cover pick against another cooling ticket. Buy early only by sacrificing that want. Cut on Blank is refused.
enum CutCover {
    static func offeredHours(desk: Desk, coverID: UUID, now: Date) throws -> Double {
        guard desk.fold == .cooling, let face = desk.faceWant, face.hold == .cooling else {
            throw DeskFault.cutOnBlank
        }
        guard coverID != face.id else { throw DeskFault.coverIsFace }
        guard let cover = desk.want(coverID) else { throw DeskFault.coverUnknown }
        guard cover.hold == .cooling else { throw DeskFault.coverNotCooling }
        _ = face
        return cover.remainingHours(at: now)
    }
}
