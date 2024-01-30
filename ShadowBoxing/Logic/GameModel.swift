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
    case preparing
    case playing
    case paused
    case gameOver
}

enum GameScreen {
    static func from(_ gameModel: GameModel) -> Self {
        switch gameModel.state {
        case .notStarted:
            return start
        case .preparing:
            return preparing
        case .playing:
            return emptyView
        case .paused:
            return emptyView
        case .gameOver:
            return emptyView
        }
    }

    case start
    case preparing
    case emptyView
}

@Observable
class GameModel {
    private(set) var level: Level?
    private(set) var state: GameState
    /// Should be updated after `shouldShowImmersiveView` changes
    private(set) var immersiveViewShown = false
    // Used to handle multiple state changes in a single transaction.
    // Note: every state change that needs to be displayed to the user should be done in a transaction.
    private(set) var transactions: UUID = UUID()

    /// Depends on the game state.
    /// For the fact the immersive is shown responsible `immersiveViewShown` property
    var shouldShowImmersiveView: Bool {
        switch self.state {
        case .notStarted, .preparing, .paused, .gameOver:
            return false
        case .playing:
            return true
        }
    }

    init(level: Level? = nil, state: GameState) {
        self.level = level
        self.state = state
    }

    func prepareGame(_ level: Level) {
        self.level = level
        self.state = .preparing
        self.transactions = UUID()
    }

    func startGame() {
        self.state = .playing
        self.transactions = UUID()
    }

    func finishGame() {
        self.level = nil
        self.state = .notStarted
        self.transactions = UUID()
    }

    func immersiveViewVisibility(isShown: Bool) {
        self.immersiveViewShown = isShown
        self.transactions = UUID()
    }
}

