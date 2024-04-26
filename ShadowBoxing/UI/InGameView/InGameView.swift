import SwiftUI
import RealityKit
import ARKit
import Foundation

struct InGameView: View {
    @Environment(GameModel.self) var gameModel

    var body: some View {
        VStack {
            Text("Time left: \(self.gameModel.roundState.timeLeft) s")
            Text("Combo multiplier x\(self.gameModel.roundState.comboMultiplier)")
                .bold()
            Text("Your score \(self.gameModel.roundState.score)")
                .underline()
            Button("Finish") {
                self.gameModel.finishGame()
            }
            .padding()
//            Button("Pause") {
//                // TODO: Implement pausing
//            }
//            .padding()
        }
        .font(.system(size: 30))
        .padding(20)
        .glassBackgroundEffect()
    }
}

#Preview {
    InGameView()
}

extension GameModel {
    struct RoundState {
        let timeLeft: Int
        let comboMultiplier: Int
        let score: Int
    }

    var roundState: RoundState {
        RoundState(timeLeft: Int(self.round.map(\.timeLeft).map { $0 / 1000 }?.rounded(.toNearestOrEven) ?? 0),
                   comboMultiplier: self.round.map(\.comboMultiplier) ?? 0,
                   score: self.round.map(\.score) ?? 0)
    }
}
