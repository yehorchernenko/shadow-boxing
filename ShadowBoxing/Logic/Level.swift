import Foundation

struct Level: Identifiable {
    let id = UUID()
    let name: String
    let speed: Float
    let image: String
    let punchPoints: Int

    static var easy: Level {
        Level(name: "Easy", speed: Float(Constants.saved.easySpeed), image: "flag.2.crossed", punchPoints: 100)
    }

    static var medium: Level {
        Level(name: "Medium", speed: Float(Constants.saved.mediumSpeed), image: "flag.and.flag.filled.crossed", punchPoints: 200)
    }
    
    static var hard: Level {
        Level(name: "Hard", speed: Float(Constants.saved.hardSpeed), image: "flag.2.crossed.fill", punchPoints: 300)
    }
}
