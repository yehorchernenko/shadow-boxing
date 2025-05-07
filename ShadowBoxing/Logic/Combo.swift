import Foundation

struct Combo: Hashable {
    let id: UUID
    let complexity: Double
    let steps: [RoundStep]

    /// Basic
    static var jabJab: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 0, steps: [
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.jab(comboID: id))
        ])
    }

    static var jabCross: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 0.2, steps: [
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.cross(comboID: id))
        ])
    }

    static var jabJabCross: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 0.2, steps: [
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.cross(comboID: id))
        ])
    }

    static var jabCrossLeadHook: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 0.5, steps: [
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.cross(comboID: id)),
            .delay(.shortBreak),
            .punch(.leadHook(comboID: id))
        ])
    }
    
    // New combos
    static var jabCrossUppercut: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 0.5, steps: [
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.cross(comboID: id)),
            .delay(.shortBreak),
            .punch(.rearUppercut(comboID: id))
        ])
    }
    
    static var crossHookCross: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 0.6, steps: [
            .punch(.cross(comboID: id)),
            .delay(.shortBreak),
            .punch(.leadHook(comboID: id)),
            .delay(.shortBreak),
            .punch(.cross(comboID: id))
        ])
    }
    
    static var jabLeadUppercutCrossHook: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 0.8, steps: [
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.leadUppercut(comboID: id)),
            .delay(.shortBreak),
            .punch(.cross(comboID: id)),
            .delay(.shortBreak),
            .punch(.leadHook(comboID: id))
        ])
    }

    /// Advanced
    static var jabCrossLeadHookRearUppercut: Combo {
        let id = UUID()
        return Combo(id: id, complexity: 1, steps: [
            .punch(.jab(comboID: id)),
            .delay(.shortBreak),
            .punch(.cross(comboID: id)),
            .delay(.shortBreak),
            .punch(.leadHook(comboID: id)),
            .delay(.shortBreak),
            .punch(.rearUppercut(comboID: id))
        ])
    }

    /// Don't forget to add new combos to the `allCombos` list
    static var allCombos: [Combo] {
        [
            .jabJab,
            .jabCross,
            .jabJabCross,
            .jabCrossLeadHook,
            .jabCrossUppercut,
            .crossHookCross,
            .jabLeadUppercutCrossHook,
            .jabCrossLeadHookRearUppercut,
        ]
    }

    static var randomEasyCombo: Combo {
        Combo.allCombos.filter { $0.complexity < 0.2 }.random()
    }

    static var randomMediumCombo: Combo {
        Combo.allCombos.filter { $0.complexity >= 0.2 && $0.complexity <= 0.5 }.random()
    }
    
    static var randomHardCombo: Combo {
        Combo.allCombos.filter { $0.complexity > 0.5 }.random()
    }
}

extension Array where Element == Combo {
    /// Random element or jab
    func random() -> Combo {
        randomElement() ?? .init(id: UUID(), complexity: 0, steps: [.punch(.jab())])
    }
}

extension Array where Element == Punch {
    /// Random element or jab
    func random() -> Punch {
        randomElement() ?? .jab()
    }
}
