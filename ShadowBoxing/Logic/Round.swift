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

    /// Generate a round with steps based on the difficulty level
    static func generateSteps(level: Level) -> [RoundStep] {
        // Create empty steps array
        var steps: [RoundStep] = []
        
        // Add an initial warmup section
        if Bool.random() {
            steps.append(.dodgeOrPunch)
            steps.append(.delay(.shortBreak))
        }
        
        // Select combos based on level complexity
        switch level.complexity {
        case .easy:
            // Easy level: mostly basic combos with longer breaks
            for _ in 1...10 {
                steps.append(.combo(.randomEasyCombo))
                steps.append(.delay(.longBreak))
                
                // Add occasional dodge for variety
                if Bool.random() && Bool.random() && Bool.random() {
                    steps.append(.dodgeOrPunch)
                    steps.append(.delay(.shortBreak))
                }
            }
            
        case .medium:
            // Medium level: mix of basic and medium combos
            for _ in 1...15 {
                if Bool.random() {
                    steps.append(.combo(.randomEasyCombo))
                } else {
                    steps.append(.combo(.randomMediumCombo))
                }
                
                // Medium level has a mix of break lengths
                steps.append(.delay(Bool.random() ? .shortBreak : .longBreak))
                
                // Less frequent dodges
                if Bool.random() && Bool.random() {
                    steps.append(.dodgeOrPunch)
                    steps.append(.delay(.shortBreak))
                }
            }
            
        case .hard:
            // Hard level: more advanced combos with shorter breaks
            for _ in 1...20 {
                // Weighted random selection favoring harder combos
                let random = Double.random(in: 0...1)
                if random < 0.2 {
                    // Basic (20% chance)
                    steps.append(.combo(.randomEasyCombo))
                } else if random < 0.6 {
                    // Intermediate (40% chance)
                    steps.append(.combo(.randomMediumCombo))
                } else {
                    // Advanced (40% chance)
                    steps.append(.combo(.randomHardCombo))
                }
                
                // Hard level mostly has short breaks
                steps.append(.delay(.shortBreak))
                
                // Frequent dodges mixed in
                if Bool.random() {
                    steps.append(.dodgeOrPunch)
                    steps.append(.delay(.shortBreak))
                }
            }
        }
        
        return steps
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
