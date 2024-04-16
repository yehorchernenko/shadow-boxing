import OSLog

private let kInGameSubsystem = "InGame"

struct Log {
    static let roundStep = Logger(subsystem: kInGameSubsystem, category: "Round step")
    static let collision = Logger(subsystem: kInGameSubsystem, category: "Collision")
}
