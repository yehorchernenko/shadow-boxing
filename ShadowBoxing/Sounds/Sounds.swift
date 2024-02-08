import Foundation
import RealityKit

// TODO: - Add copyright
struct Sounds {
    enum Punch {
        /// https://freesound.org/people/CastIronCarousel/sounds/216785/
        case straight

        /// https://freesound.org/people/MattRuthSound/sounds/561644/
        case missed

        var url: URL {
            switch self {
            case .straight:
                return Bundle.main.url(forResource: "punch_straight", withExtension: "mp3")!
            case .missed:
                return Bundle.main.url(forResource: "punch_missed", withExtension: "mp3")!
            }
        }

        var audioResource: AudioResource {
            switch self {
            case .straight:
                return Self.straightAudioResource
            case .missed:
                return Self.missedAudioResource
            }
        }

        private static let straightAudioResource = try! AudioFileResource.load(contentsOf: Sounds.Punch.straight.url)

        private static let missedAudioResource = try! AudioFileResource.load(contentsOf: Sounds.Punch.missed.url)
    }
}
