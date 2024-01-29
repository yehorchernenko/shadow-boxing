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
                    .resizableWindow(to: CGSize(width: 800, height: 600))
            case .preparing:
                PrepareView()
                    .resizableWindow(to: CGSize(width: 800, height: 600))
            case .score:
                VStack {
                    Text("Your score")
                    Button("Finish") {
                        self.gameModel.finishGame()
                    }
                }
                    .resizableWindow(to: CGSize(width: 200, height: 200))
            }
        }
        .environment(self.gameModel)
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
