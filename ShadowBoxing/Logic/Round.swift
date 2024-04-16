import Foundation

enum RoundStep: Hashable {
    case delay(TimeInterval)
    case punch(Punch)
    case combo(Combo)
    case dodge
}

extension RoundStep {
    /// Returns random step
    static var dodgeOrPunch: RoundStep {
        Bool.random() ? .dodge : .punch([.jab(), .cross()].random())
    }
}

struct Round {
    let steps: [RoundStep]
    let level: Level
    var timeLeft: TimeInterval
    var score: Int
    var comboMultiplier: Int
    // This is used to handle finished combos. It stores number of punches in a combo.
    // When value is equal 0 it means user successfully finished the combo
    var combosStatus: [UUID: Int]

    init(level: Level) {
        self.level = level
        self.steps = Self.generateSteps(level: level)

        /// Calculate round duration
        /// `startDelay` is a time before the first combo reach the user`
        /// This magic number should be replaced with duration that entity reach the user
        let startDelay = 100 / level.speed
        self.timeLeft = steps.duration + Double(startDelay)
        self.score = 0
        self.comboMultiplier = 1
        // Count initial number of punches in combo
        self.combosStatus = self.steps.punchesByComboIDs.reduce(into: [UUID: Int]()) { result, comboID in
            result[comboID] = (result[comboID] ?? 0) + 1
        }
    }

    mutating func handlePunch(_ punch: Punch) {
        defer {
            self.score += self.level.punchPoints * self.comboMultiplier
        }

        guard let punchComboID = punch.comboID else { return }
        self.combosStatus[punchComboID, default: 0] -= 1

        if self.combosStatus[punchComboID] == 0 {
            self.comboMultiplier += 1
        }
    }

    mutating func missedCombo() {
        self.comboMultiplier = 1
    }

    /// Should be adjusted by select level
    static func generateSteps(level: Level) -> [RoundStep] {
        let startCombos = Combo.allCombos.filter { $0.complexity < 0.2 }
        let easyCombos = Combo.allCombos.filter { $0.complexity < 0.5 }
        let hardCombos = Combo.allCombos.filter { $0.complexity > 0.5 }

        // BUG: Combos start, easy and hard combos always have the same ID. This breaks logic for handling finished combos.
        return [
            .dodgeOrPunch,
            .delay(.shortBreak),
            
            .combo(startCombos.random()),
            .delay(.longBreak),
            .combo(startCombos.random()),
            .delay(.longBreak),

            .dodgeOrPunch,
            .delay(.shortBreak),

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

extension Array where Element == RoundStep {
    var duration: TimeInterval {
        reduce(0) { result, step in
            switch step {
            case .delay(let milliseconds):
                return result + milliseconds
            case .combo(let combo):
                return result + combo.steps.duration
            default:
                return result
            }
        }
    }

    var punchesByComboIDs: [UUID] {
        reduce([UUID]()) { result, step in
            switch step {
            case .combo(let combo):
                return result + combo.steps.punchesByComboIDs
            case .punch(let punch):
                return result + [punch.comboID].compactMap { $0 }
            default:
                return result
            }
        }
    }

}
