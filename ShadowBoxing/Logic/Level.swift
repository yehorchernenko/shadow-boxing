import Foundation

struct Level: Identifiable {
    let id = UUID()
    let name: String
    let speed: Float
    let image: String

    static let easy = Level(name: "Easy", speed: 0.01, image: "flag.2.crossed")
    static let medium = Level(name: "Medium", speed: 0.015, image: "flag.and.flag.filled.crossed")
    static let hard = Level(name: "Hard", speed: 0.02, image: "flag.2.crossed.fill")
}
