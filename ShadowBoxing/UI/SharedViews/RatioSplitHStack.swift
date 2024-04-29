import SwiftUI

struct RatioSplitHStack<L, R>: View where L: View, R: View {
    let leftWidthRatio: CGFloat
    let leftContent: L
    let rightContent: R
    init(leftWidthRatio: CGFloat, @ViewBuilder leftContent: @escaping () -> L, @ViewBuilder rightContent: @escaping () -> R) {
        self.leftWidthRatio = leftWidthRatio
        self.leftContent = leftContent()
        self.rightContent = rightContent()
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: proxy.size.width * leftWidthRatio)
                    .overlay(leftContent)
                Color.clear
                    .overlay(rightContent)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    RatioSplitHStack(leftWidthRatio: 0.4) {
        Color.blue
    } rightContent: {
        Color.yellow
    }
}
