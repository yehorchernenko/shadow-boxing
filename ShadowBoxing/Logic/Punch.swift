import Foundation

struct Punch: Hashable {
    enum Kind: String {
        case jab
        case cross
        case hook
        case uppercut
    }

    let kind: Kind
    let hand: Hand
    let comboID: UUID?

    static func jab(comboID: UUID? = nil) -> Punch {
        Punch(kind: .jab, hand: .leading, comboID: comboID)
    }
    static func cross(comboID: UUID? = nil) -> Punch {
        Punch(kind: .cross, hand: .rear, comboID: comboID)
    }

    static func leadHook(comboID: UUID? = nil) -> Punch {
        Punch(kind: .hook, hand: .leading, comboID: comboID)
    }

    static func rearHook(comboID: UUID? = nil) -> Punch {
        Punch(kind: .hook, hand: .rear, comboID: comboID)
    }

    static func leadUppercut(comboID: UUID? = nil) -> Punch {
        Punch(kind: .uppercut, hand: .leading, comboID: comboID)
    }

    static func rearUppercut(comboID: UUID? = nil) -> Punch {
        Punch(kind: .uppercut, hand: .rear, comboID: comboID)
    }
}
