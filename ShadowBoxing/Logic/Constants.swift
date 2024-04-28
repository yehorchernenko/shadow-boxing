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
}
