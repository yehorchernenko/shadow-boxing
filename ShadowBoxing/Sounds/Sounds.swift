import Foundation
import RealityKit

// TODO: - Add copyright
struct Sounds {
    enum Punch {
        /// https://freesound.org/people/CastIronCarousel/sounds/216785/
        /// https://freesound.org/people/MattRuthSound/sounds/561644/
        case hit

        /// https://pixabay.com/sound-effects/fist-fight-192117/
        case missed

        var url: URL {
            switch self {
            case .hit:
                return ["punch_straight", "punch_straight_2"]
                    .randomElement().flatMap { resource in
                        Bundle.main.url(forResource: resource, withExtension: "mp3")
                    }!
            case .missed:
                return Bundle.main.url(forResource: "punch_missed", withExtension: "mp3")!
            }
        }

        var audioResource: AudioResource {
            switch self {
            case .hit:
                return try! AudioFileResource.load(contentsOf: Punch.hit.url)
            case .missed:
                return try! AudioFileResource.load(contentsOf: Punch.missed.url)
            }
        }
    }

    enum Dodge {
        case hit

        /// https://pixabay.com/sound-effects/fist-fight-192117/
        case missed

        var url: URL {
            switch self {
            case .hit:
                return Bundle.main.url(forResource: "dodge_hit", withExtension: "mp3")!
            case .missed:
                return Bundle.main.url(forResource: "dodge_missed", withExtension: "mp3")!
            }
        }

        var audioResource: AudioResource {
            switch self {
            case .hit:
                return try! AudioFileResource.load(contentsOf: Dodge.hit.url)
            case .missed:
                return try! AudioFileResource.load(contentsOf: Dodge.missed.url)
            }
        }
    }

}
