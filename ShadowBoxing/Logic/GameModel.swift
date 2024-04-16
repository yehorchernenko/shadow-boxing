import Foundation

enum GameState {
    case notStarted
    case preparing
    case playing
    case paused
    case gameOver
}

@Observable
class GameModel {
    private(set) var level: Level?
    private(set) var round: Round?
    private(set) var state: GameState
    private(set) var roundCountdownTimer = Timer()

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
        guard let level = self.level else {
            assertionFailure("Level should be set before starting the game.")
            return
        }

        self.round = Round(level: level)
        self.state = .playing

        self.roundCountdownTimer.invalidate()
        self.roundCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.round?.timeLeft -= 1000 // ms

            if let timeLeft = self.round?.timeLeft, timeLeft <= 0 {
                /// Should be replaced with game over to show user results
                self.finishGame()
            }
        })

        self.transactions = UUID()
    }

    func finishGame() {
        self.level = nil
        self.state = .notStarted
        self.roundCountdownTimer.invalidate()
        self.transactions = UUID()
    }

    func immersiveViewVisibility(isShown: Bool) {
        self.immersiveViewShown = isShown
        self.transactions = UUID()
    }

    // Round logic
    func handlePunch(_ punch: Punch) {
        self.round?.handlePunch(punch)
        self.transactions = UUID()
    }

    func missedCombo() {
        self.round?.missedCombo()
        self.transactions = UUID()
    }
}


