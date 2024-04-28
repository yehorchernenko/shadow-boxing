import SwiftUI

struct DeveloperToolsView: View {
    @UserDefaultCodable(key: "constants", defaultValue: .default)
    var constants: Constants

    var body: some View {
        List {
            Section("Constants") {
                HStack {
                    Text("Level Easy - speed")
                    Slider(
                        value: $constants.easySpeed,
                        in: 0.005...0.05,
                        step: 0.001)
                    Text("\(constants.easySpeed)")
                }

                HStack {
                    Text("Level Medium - speed")
                    Slider(
                        value: $constants.mediumSpeed,
                        in: 0.005...0.05,
                        step: 0.001)
                    Text("\(constants.mediumSpeed)")
                }

                HStack {
                    Text("Level Hard - speed")
                    Slider(
                        value: $constants.hardSpeed,
                        in: 0.005...0.05,
                        step: 0.001)
                    Text("\(constants.hardSpeed)")
                }
            }
        }
    }
}

#Preview {
    DeveloperToolsView()
}
