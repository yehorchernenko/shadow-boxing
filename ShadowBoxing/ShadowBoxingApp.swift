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
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var immersionState: ImmersionStyle = .mixed
    @State private var gameModel = GameModel(state: .notStarted)

    var body: some Scene {
        Group {
            WindowGroup(id: kMainWindowID) {
                RootView()
                    .environment(self.gameModel)
            }
            .windowResizability(.contentSize)

            ImmersiveSpace(id: kImmersiveSpaceID) {
                ImmersiveView()
                    .environment(self.gameModel)
            }
            .immersionStyle(selection: $immersionState, in: .mixed)
        }
        .onChange(of: self.gameModel.shouldShowImmersiveView) { _, showImmersive in
            Task { @MainActor in
                if showImmersive {
                    await self.showImmersiveSpace()
                } else {
                    await self.showWindow()
                }
            }
        }
    }

    init() {
        BillboardSystem.registerSystem()
        BillboardComponent.registerComponent()
    }

    private func showImmersiveSpace() async {
        guard !self.gameModel.immersiveViewShown else { return }

        switch await self.openImmersiveSpace(id: kImmersiveSpaceID) {
        case .opened:
            self.dismissWindow(id: kMainWindowID)
            self.gameModel.immersiveViewVisibility(isShown: true)
        case .error, .userCancelled:
            fallthrough
        @unknown default:
            break
        }
    }

    private func showWindow() async {
        guard self.gameModel.immersiveViewShown else { return }

        await self.dismissImmersiveSpace()
        self.openWindow(id: kMainWindowID)
        self.gameModel.immersiveViewVisibility(isShown: false)
    }
}
