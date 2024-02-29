import Foundation

struct Combo {
    let id: UUID
    let complexity: Double
    let steps: [RoundStep]

    /// Basic
    static var jabJab: Combo {
        Combo(id: UUID(), complexity: 0, steps: [
            .punch(.jab),
            .delay(.shortBreak),
            .punch(.jab)
        ])
    }

    static var jabCross: Combo {
        Combo(id: UUID(), complexity: 0.2, steps: [
            .punch(.jab),
            .delay(.shortBreak),
            .punch(.cross)
        ])
    }

    static var jabJabCross: Combo {
        Combo(id: UUID(), complexity: 0.2, steps: [
            .punch(.jab),
            .delay(.shortBreak),
            .punch(.jab),
            .delay(.shortBreak),
            .punch(.cross)
        ])
    }

    static var jabCrossLeadHook: Combo {
        Combo(id: UUID(), complexity: 0.5, steps: [
            .punch(.jab),
            .delay(.shortBreak),
            .punch(.cross),
            .delay(.shortBreak),
            .punch(.leadHook)
        ])
    }

    // jab-cross-uppercut
    // cross-hook-cross

    /// Advanced
    static var jabCrossLeadHookRearUppercut: Combo {
        Combo(id: UUID(), complexity: 1, steps: [
            .punch(.jab),
            .delay(.shortBreak),
            .punch(.cross),
            .delay(.shortBreak),
            .punch(.leadHook),
            .delay(.shortBreak),
            .punch(.rearUppercut)
        ])
    }
    // Jab - Uppercut - Cross - Hook
    // Double Jab - Cross - Lead Hook - Rear Uppercut
    // Cross - Lead Uppercut - Rear Hook - Cross

    /// Don't forget to add new combos to the `allCombos` list
    static var allCombos: [Combo] = [
        .jabJab,
        .jabCross,
        .jabJabCross,
        .jabCrossLeadHook,
        .jabCrossLeadHookRearUppercut,
    ]
}

extension Array where Element == Combo {
    /// Random element or jab
    func random() -> Combo {
        randomElement() ?? .init(id: UUID(), complexity: 0, steps: [.punch(.jab)])
    }
}

extension Array where Element == Punch {
    /// Random element or jab
    func random() -> Punch {
        randomElement() ?? .jab
    }
}
