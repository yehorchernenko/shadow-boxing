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
        .onChange(of: self.gameModel.transactions) {
            if case .playing = self.gameModel.state {
                Task { @MainActor in
                    switch await self.openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        break
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environment(GameModel(state: .notStarted))
}
