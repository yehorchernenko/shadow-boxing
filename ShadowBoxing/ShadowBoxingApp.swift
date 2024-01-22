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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
//        .immersionStyle(selection: $immersionState, in: .mixed)
    }
}
