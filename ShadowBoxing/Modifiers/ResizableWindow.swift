import SwiftUI

// Define a custom view modifier
// NOT USED
struct ResizableWindowModifier: ViewModifier {
    @State private var resizingContentOpacity = 0.0
    var size: CGSize

    private var windowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes.first as? UIWindowScene
    }

    func body(content: Content) -> some View {
        content
            .opacity(self.resizingContentOpacity)
            .onAppear {
                self.resizeWindow(to: size)
                withAnimation(.easeInOut.delay(0.2)) {
                    self.resizingContentOpacity = 1
                }
            }
    }

    private func resizeWindow(to size: CGSize) {
        self.windowScene?.sizeRestrictions?.minimumSize = size
        self.windowScene?.sizeRestrictions?.maximumSize = size
    }
}

// Extension to make the modifier easier to apply
extension View {
    func resizableWindow(to size: CGSize) -> some View {
        self.modifier(ResizableWindowModifier(size: size))
    }
}
