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
    @State private var game = GameModel(state: .notStarted)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(game)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
//        .immersionStyle(selection: $immersionState, in: .mixed)
    }
}
