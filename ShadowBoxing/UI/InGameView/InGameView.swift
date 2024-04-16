import SwiftUI
import RealityKit
import ARKit
import Foundation

struct InGameView: View {
    @Environment(GameModel.self) var gameModel

    var body: some View {
        VStack {
            Text("Time left \(self.gameModel.round.map(\.timeLeft).map { $0 / 1000 }?.rounded(.toNearestOrEven) ?? 0)")
            Text("Combo multiplier \(self.gameModel.round.map(\.comboMultiplier) ?? 0)")
            Text("Your score \(self.gameModel.round.map(\.score) ?? 0)")
            Button("Finish") {
                self.gameModel.finishGame()
            }
            .padding()
            Button("Pause") {
                // TODO: Implement pausing
            }
            .padding()
        }
        .font(.system(size: 30))
        .padding(20)
        .glassBackgroundEffect()
    }
}

#Preview {
    InGameView()
}
