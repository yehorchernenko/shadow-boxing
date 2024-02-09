import SwiftUI

struct StartView: View {
    @Environment(GameModel.self) var gameModel

    var levels = [Level.easy, .medium, .hard]

    var body: some View {
        VStack {
            HStack {
                ForEach(levels) { level in
                    LevelCardView(level: level) { level in
                        self.gameModel.prepareGame(level)
                        self.gameModel.startGame()
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    StartView()
        .environment(GameModel(state: .notStarted))
}

