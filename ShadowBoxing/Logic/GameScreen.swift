import Foundation

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
