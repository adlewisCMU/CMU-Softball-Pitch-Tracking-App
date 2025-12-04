import Foundation

struct PitchOutcome {
    var isStrike: Bool
    var isHBP: Bool
    var didSwing: Bool
    var madeContact: Bool
    var isHit: Bool
    var isOut: Bool
    var isError: Bool
}

enum PitchResultType {
    case swingStrike
    case swingFoul
    case swingHit
    case swingOut
    case swingError
    case noSwingStrike
    case noSwingBall
    case hbp

    var outcome: PitchOutcome {
        switch self {
        case .swingStrike:
            return PitchOutcome(isStrike: true, isHBP: false, didSwing: true, madeContact: false, isHit: false, isOut: false, isError: false)
        case .swingFoul:
            return PitchOutcome(isStrike: true, isHBP: false, didSwing: true, madeContact: true, isHit: false, isOut: false, isError: false)
        case .swingHit:
            return PitchOutcome(isStrike: true, isHBP: false, didSwing: true, madeContact: true, isHit: true, isOut: false, isError: false)
        case .swingOut:
            return PitchOutcome(isStrike: true, isHBP: false, didSwing: true, madeContact: true, isHit: false, isOut: true, isError: false)
        case .swingError:
            return PitchOutcome(isStrike: true, isHBP: false, didSwing: true, madeContact: true, isHit: false, isOut: false, isError: true)
        case .noSwingStrike:
            return PitchOutcome(isStrike: true, isHBP: false, didSwing: false, madeContact: false, isHit: false, isOut: false, isError: false)
        case .noSwingBall:
            return PitchOutcome(isStrike: false, isHBP: false, didSwing: false, madeContact: false, isHit: false, isOut: false, isError: false)
        case .hbp:
            return PitchOutcome(isStrike: false, isHBP: true, didSwing: false, madeContact: false, isHit: false, isOut: false, isError: false)
        }
    }
}
