import Foundation
import SwiftUI

struct Constants: Codable, Equatable {
    static let `default` = Constants()
    @UserDefaultCodable(key: "constants", defaultValue: .default)
    static var saved: Constants

    // Mark: - Levels speed
    var easySpeed: Double = 0.01
    var mediumSpeed: Double = 0.015
    var hardSpeed: Double = 0.02

    // Mark: - Entities
    var targetEntitySpawnHeight: Double = 1.5
    var targetEntitySpawnDistance: Double = -7
    var targetUserHeightOffest: Float = 0.6

    var dodgeEntitySpawnHeight: Double = 1.9
    var dodgeEntitySpawnDistance: Double = -7

    // Mark: - Round

    var roundShortBreak: Double = 700
    var roundLongBreak: Double = 3000
}
