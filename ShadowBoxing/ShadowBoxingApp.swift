//
//  ShadowBoxingApp.swift
//  ShadowBoxing
//
//  Created by Yehor Chernenko on 21.01.2024.
//

import SwiftUI

fileprivate let kMainWindowID = "MainWindow"
fileprivate let kImmersiveSpaceID = "ImmersiveSpace"

@main
struct ShadowBoxingApp: App {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var immersionState: ImmersionStyle = .mixed
    @State private var gameModel = GameModel(state: .notStarted)

    var body: some Scene {
        WindowGroup(id: kMainWindowID) {
            RootView()
                .environment(self.gameModel)
                .onChange(of: self.gameModel.isImmersed) { _, showImmersive in
                    guard showImmersive else { return }

                    Task { @MainActor in
                        switch await self.openImmersiveSpace(id: kImmersiveSpaceID) {
                        case .opened:
                            self.dismissWindow(id: kMainWindowID)
                        case .error, .userCancelled:
                            fallthrough
                        @unknown default:
                            break
                        }
                    }
                }
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: kImmersiveSpaceID) {
            ImmersiveView()
                .environment(self.gameModel)
        }
        .immersionStyle(selection: $immersionState, in: .mixed)
    }

    init() {
        BillboardSystem.registerSystem()
        BillboardComponent.registerComponent()
    }
}
