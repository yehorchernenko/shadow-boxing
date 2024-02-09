import SwiftUI

struct PrepareView: View {
    @Environment(GameModel.self) var gameModel

    var body: some View {
        CountdownView()
            .frame(width: 300, height: 300)
            .environment(self.gameModel)
    }
}

#Preview {
    PrepareView()
        .environment(GameModel(state: .preparing))
}
