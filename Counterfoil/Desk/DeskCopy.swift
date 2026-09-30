import Foundation

/// Role: Desk. Dry will-call copy for fold labels and refusals. Colour is never the only signal.
enum DeskCopy {
    static func hold(_ fold: HoldFold, fate: ClaimFate?) -> String {
        switch fold {
        case .blank:
            return "Blank"
        case .cooling:
            return "Cooling"
        case .released:
            switch fate {
            case .bought: return "Released, bought"
            case .dropped: return "Released, dropped"
            case .cut: return "Released, cut"
            case nil: return "Released"
            }
        }
    }

    static func holdSymbol(_ fold: HoldFold, fate: ClaimFate?) -> String {
        switch fold {
        case .blank: return "square.dashed"
        case .cooling: return "clock"
        case .released:
            switch fate {
            case .bought: return "checkmark.circle"
            case .dropped: return "xmark.circle"
            case .cut: return "scissors"
            case nil: return "checkmark.circle"
            }
        }
    }

    static func fault(_ fault: DeskFault) -> String {
        switch fault {
        case .cutOnBlank: return "Cut needs a cooling ticket."
        case .stampReleased: return "Released tickets stay closed."
        case .wantUnknown: return "That want is gone."
        case .coverUnknown: return "That cover is gone."
        case .coverNotCooling: return "Cover must still be cooling."
        case .coverIsFace: return "Pick a different ticket."
        case .emptyName: return "Name the want."
        case .invalidPrice: return "Price must be above zero."
        case .invalidPriority: return "Priority must be above zero."
        case .invalidNecessity: return "Necessity is 0 to 100."
        case .invalidDiscretion: return "Discretion is 0 to 100."
        case .invalidLimit: return "Limit must be above zero."
        case .railStillRunning: return "Wait or cut."
        case .noEligibleWant: return "File a want first."
        case .fateNotRelease: return "Pick bought or dropped."
        }
    }

    static func limitShift(draft: Double, saved: Double) -> String {
        if abs(draft - saved) < 0.01 {
            return "This limit matches the hours already on the rail."
        }
        if draft > saved {
            return "Raising the limit shortens hours on the live tickets."
        }
        return "Lowering the limit lengthens hours on the live tickets."
    }
}
