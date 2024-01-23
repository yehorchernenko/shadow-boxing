//
//  ShadowBoxingApp.swift
//  ShadowBoxing
//
//  Created by Yehor Chernenko on 21.01.2024.
//

import SwiftUI

@main
struct ShadowBoxingApp: App {
    @State private var immersionState: ImmersionStyle = .mixed
    @State private var gameModel = GameModel(state: .notStarted)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(gameModel)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
//        .immersionStyle(selection: $immersionState, in: .mixed)
    }
}
