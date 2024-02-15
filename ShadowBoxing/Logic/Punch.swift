import Foundation

struct Punch {
    enum Kind {
        case jab
        case cross
        case hook
        case uppercut
    }

    let kind: Kind
    let hand: Hand

    static var jab: Punch = Punch(kind: .jab, hand: .leading)
    static var cross: Punch = Punch(kind: .cross, hand: .rear)

    static var leadHook: Punch = Punch(kind: .hook, hand: .leading)
    static var rearHook: Punch = Punch(kind: .hook, hand: .rear)

    static var leadUppercut: Punch = Punch(kind: .uppercut, hand: .leading)
    static var rearUppercut: Punch = Punch(kind: .uppercut, hand: .rear)
}
