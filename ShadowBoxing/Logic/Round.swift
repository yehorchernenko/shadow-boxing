import Foundation

enum RoundStep {
    case delay(TimeInterval)
    case punch(Punch)
    case combo(Combo)
    case dodge
}

struct Round {
    let steps: [RoundStep]
    let level: Level

    /// Should be adjusted by select level
    static func generateSteps() -> [RoundStep] {
        let startCombos = Combo.allCombos.filter { $0.complexity < 0.2 }
        let easyCombos = Combo.allCombos.filter { $0.complexity < 0.5 }
        let hardCombos = Combo.allCombos.filter { $0.complexity > 0.5 }

        return [
            .combo(startCombos.random()),
            .delay(.longBreak),
            .combo(startCombos.random()),
            .delay(.longBreak),

            .combo(easyCombos.random()),
            .delay(.longBreak),
            .combo(easyCombos.random()),
            .delay(.longBreak),
            .combo(easyCombos.random()),
            .delay(.longBreak),
            
            .combo((easyCombos + hardCombos).random()),
            .delay(.longBreak),
            .combo((easyCombos + hardCombos).random()),
            .delay(.longBreak),
            .combo((easyCombos + hardCombos).random()),
        ]
    }
}
