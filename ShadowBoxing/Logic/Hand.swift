import Foundation

enum Hand: String, CaseIterable {
    case left
    case right

    /// Leading and rear hands are relative to the boxer's stance
    /// Should be adjustable in the settings
    static var leading: Hand = .left
    static var rear: Hand = .right
}
