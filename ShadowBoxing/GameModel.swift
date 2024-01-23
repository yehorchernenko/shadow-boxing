import Foundation

struct Level: Identifiable {
    enum Speed {
        case easy
        case medium
        case hard
    }
    
    let id = UUID()
    let name: String
    let speed: Speed
    let image: String

    static let easy = Level(name: "Easy", speed: .easy, image: "flag.2.crossed")
    static let medium = Level(name: "Medium", speed: .medium, image: "flag.and.flag.filled.crossed")
    static let hard = Level(name: "Hard", speed: .hard, image: "flag.2.crossed.fill")
}

enum GameState {
    case notStarted
    case playing
    case paused
    case gameOver
}

enum GameScreen {
    static func from(_ gameModel: GameModel) -> Self {
        return start
    }

    case start
}

@Observable
class GameModel {
    var level: Level?
    var state: GameState

    init(level: Level? = nil, state: GameState) {
        self.level = level
        self.state = state
    }
}


