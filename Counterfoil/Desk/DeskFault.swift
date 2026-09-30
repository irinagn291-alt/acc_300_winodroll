import Foundation

/// Role: Desk. Typed refusals of Stamp, Cut, file, and zero-rail release. Views map these. Never a crash.
enum DeskFault: Error, Equatable, Sendable {
    case cutOnBlank
    case stampReleased
    case wantUnknown
    case coverUnknown
    case coverNotCooling
    case coverIsFace
    case emptyName
    case invalidPrice
    case invalidPriority
    case invalidNecessity
    case invalidDiscretion
    case invalidLimit
    case railStillRunning
    case noEligibleWant
    case fateNotRelease
}
