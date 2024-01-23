import SwiftUI

struct LevelCardView: View {
    var level: Level
    var tapAction: (Level) -> Void
    @State private var animationIsActive = false

    var body: some View {
        HStack {
            VStack {
                Image(systemName: level.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text(level.name)
            }
            .padding()
        }
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .hoverEffect(.automatic)
        .onTapGesture {
            self.tapAction(self.level)
        }
    }
}

#Preview {
    LevelCardView(level: .easy) { _ in

    }
}
