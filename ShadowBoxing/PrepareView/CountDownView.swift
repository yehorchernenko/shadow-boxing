import SwiftUI

struct CountdownView: View {
    @Environment(GameModel.self) var gameModel
    @State private var countdown = 3
    @State private var scale = 2
    @State private var opacity = 1

    var body: some View {
        Gauge(value: Double(self.countdown) / 3) {
            EmptyView()
        }
        .labelsHidden()
        .gaugeStyle(.accessoryCircularCapacity)
        .scaleEffect(x: 5, y: 5, z: 1)
        .overlay {
            Text("\(countdown)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .scaleEffect(CGFloat(scale))
                .opacity(Double(opacity))
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                guard self.countdown > 0 else {
                    timer.invalidate()
                    self.gameModel.startGame()
                    return
                }

                self.scale = 1 // Shrink the number
                self.opacity = 1
                withAnimation {
                    self.scale = 2 // Enlarge the number
                    self.countdown -= 1
                }
            }
        }
    }
}

#Preview {
    CountdownView()
}
