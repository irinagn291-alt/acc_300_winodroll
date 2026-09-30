import Foundation

/// Role: Desk. Preference keys. Snapshot is JSON Data under ctf.desk.v1. Demo is Simulator only.
enum DeskKey {
    static let snapshot = "ctf.desk.v1"
    static let backup = "ctf.desk.v1.backup"
    static let demo = "ctf.demo.v1"
}

enum DeskCodecError: Error, Equatable, Sendable {
    case unsupportedSchema(Int)
    case corrupt
}

/// Role: Desk. One Codable DeskDocument. schemaVersion from 1. Hold case is stored. Cooling-ness is not a parallel bool.
enum DeskDocument {
    static func encode(_ desk: Desk) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        var copy = desk
        copy.schemaVersion = Desk.currentSchema
        return try encoder.encode(RootFile(desk: copy))
    }

    static func decode(_ data: Data) throws -> Desk {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let probe: SchemaProbe
        do {
            probe = try decoder.decode(SchemaProbe.self, from: data)
        } catch {
            throw DeskCodecError.corrupt
        }
        switch probe.schemaVersion {
        case 1:
            do {
                var desk = try decoder.decode(RootFile.self, from: data).desk
                desk.schemaVersion = Desk.currentSchema
                return desk
            } catch {
                throw DeskCodecError.corrupt
            }
        default:
            throw DeskCodecError.unsupportedSchema(probe.schemaVersion)
        }
    }
}

private struct SchemaProbe: Decodable {
    var schemaVersion: Int
}

private struct RootFile: Codable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var wants: [WillCall]
    var coverMarks: [CoverMark]
    var shortMarks: [ShortMark]
    var rules: DeskRule
    var faceID: UUID?

    init(desk: Desk) {
        schemaVersion = desk.schemaVersion
        onboardingComplete = desk.onboardingComplete
        wants = desk.wants
        coverMarks = desk.coverMarks
        shortMarks = desk.shortMarks
        rules = desk.rules
        faceID = desk.faceID
    }

    var desk: Desk {
        Desk(
            schemaVersion: schemaVersion,
            onboardingComplete: onboardingComplete,
            wants: wants,
            coverMarks: coverMarks,
            shortMarks: shortMarks,
            rules: rules,
            faceID: faceID
        )
    }
}
