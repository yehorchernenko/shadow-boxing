import SwiftUI

struct DeveloperToolsView: View {
    @UserDefaultCodable(key: "constants", defaultValue: .default)
    var constants: Constants

    var body: some View {
        List {
            self.levelSpeedView
            self.entitiesSettingsView
            self.roundSettingsView
        }
        .navigationTitle("Constants")
    }

    private var levelSpeedView: some View {
        Section("Level speed") {
            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Level Easy - speed")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.easySpeed,
                    in: 0.005...0.05,
                    step: 0.001)
                Text("\(constants.easySpeed)")
            }

            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Level Medium - speed")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.mediumSpeed,
                    in: 0.005...0.05,
                    step: 0.001)
                Text("\(constants.mediumSpeed)")
            }

            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Level Hard - speed")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.hardSpeed,
                    in: 0.005...0.05,
                    step: 0.001)
                Text("\(constants.hardSpeed)")
            }
        }
    }

    private var entitiesSettingsView: some View {
        Section("Entities settings") {
            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Target entity spawn height")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.targetEntitySpawnHeight,
                    in: 0.1...5,
                    step: 0.1)
                Text("\(constants.targetEntitySpawnHeight)")
            }

            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Target entity spawn distance")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.targetEntitySpawnDistance,
                    in: -20...20,
                    step: 0.5)
                Text("\(constants.targetEntitySpawnDistance)")
            }

            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Dodge entity spawn height")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.dodgeEntitySpawnHeight,
                    in: 0.1...5,
                    step: 0.1)
                Text("\(constants.dodgeEntitySpawnHeight)")
            }

            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Dodge entity spawn distance")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.dodgeEntitySpawnDistance,
                    in: -20...20,
                    step: 0.5)
                Text("\(constants.dodgeEntitySpawnDistance)")
            }
        }
    }

    private var roundSettingsView: some View {
        Section("Round settings") {
            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Break between punches")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.roundShortBreak,
                    in: 100...10000,
                    step: 100)
                Text("\(constants.roundShortBreak) ms")
            }

            RatioSplitHStack(leftWidthRatio: 0.2) {
                HStack {
                    Text("Long break between punches")
                    Spacer()
                }
            } rightContent: {
                Slider(
                    value: $constants.roundLongBreak,
                    in: 100...10000,
                    step: 100)
                Text("\(constants.roundLongBreak) ms")
            }
        }
    }
}

#Preview {
    DeveloperToolsView()
}
