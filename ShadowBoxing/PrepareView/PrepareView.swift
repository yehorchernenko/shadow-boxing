import SwiftUI

struct PrepareView: View {
    @Environment(GameModel.self) var gameModel

    var body: some View {
        CountdownView()
            .environment(self.gameModel)
    }
}

#Preview {
    PrepareView()
        .environment(GameModel(state: .preparing))
}
