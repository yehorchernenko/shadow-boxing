import SwiftUI

struct StartView: View {
    @Environment(GameModel.self) var gameModel

    var levels: [Level] {
        [.easy, .medium, .hard]
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()

                    NavigationLink("Developer tools", destination: DeveloperToolsView())
                }

                Spacer()

                HStack {
                    ForEach(levels) { level in
                        LevelCardView(level: level) { level in
                            self.gameModel.prepareGame(level)
                            self.gameModel.startGame()
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview {
    StartView()
        .environment(GameModel(state: .notStarted))
}

