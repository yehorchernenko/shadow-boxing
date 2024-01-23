import SwiftUI
import RealityKit

struct RootView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(GameModel.self) var gameModel

    var body: some View {
        VStack {
            switch GameScreen.from(self.gameModel) {
            case .start:
                StartView()
                    .environment(self.gameModel)
            }

        }
        .padding()
    }
}

#Preview {
    RootView()
        .environment(GameModel(state: .notStarted))
}
