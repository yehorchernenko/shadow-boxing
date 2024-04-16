import SwiftUI

extension View {
    public func simulatorOnlyGesture<T>(_ gesture: T, including mask: GestureMask = .all) -> some View where T : Gesture {
        #if targetEnvironment(simulator)
            self.gesture(gesture, including: mask)
        #endif
    }
}
