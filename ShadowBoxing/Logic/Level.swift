import Foundation

struct Level: Identifiable {
    enum Speed {
        case easy
        case medium
        case hard
    }

    let id = UUID()
    let name: String
    let speed: Speed
    let image: String

    static let easy = Level(name: "Easy", speed: .easy, image: "flag.2.crossed")
    static let medium = Level(name: "Medium", speed: .medium, image: "flag.and.flag.filled.crossed")
    static let hard = Level(name: "Hard", speed: .hard, image: "flag.2.crossed.fill")
}
