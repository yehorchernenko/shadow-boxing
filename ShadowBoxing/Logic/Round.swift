import Foundation

enum RoundStep {
    case delay(TimeInterval)
    case punch(Punch)
    case combo(Combo)
    case dodge
}

extension RoundStep {
    /// Returns random step
    var dodgeOrPunch: RoundStep {
        Bool.random() ? .dodge : .punch([.jab, .cross].random())
    }
}

struct Round {
    let steps: [RoundStep]
    let level: Level
    var timeLeft: TimeInterval

    init(level: Level) {
        self.level = level
        self.steps = Self.generateSteps(level: level)

        /// Calculate round duration
        /// `startDelay` is a time before the first combo reach the user`
        /// This magic number should be replaced with duration that entity reach the user
        let startDelay = 100 / level.speed
        self.timeLeft = steps.duration + Double(startDelay)
    }

    /// Should be adjusted by select level
    static func generateSteps(level: Level) -> [RoundStep] {
        let startCombos = Combo.allCombos.filter { $0.complexity < 0.2 }
        let easyCombos = Combo.allCombos.filter { $0.complexity < 0.5 }
        let hardCombos = Combo.allCombos.filter { $0.complexity > 0.5 }

        return [
            .dodge,
            .delay(.shortBreak),
            
            .combo(startCombos.random()),
            .delay(.longBreak),
            .combo(startCombos.random()),
            .delay(.longBreak),

            .dodge,
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
}
