import SwiftUI
import RealityKit
import ARKit

struct InGameView: View {
    @Environment(GameModel.self) var gameModel

    var body: some View {
        VStack {
            Button("Finish") {
                self.gameModel.finishGame()
            }
        }
    }
}

#Preview {
    InGameView()
}
