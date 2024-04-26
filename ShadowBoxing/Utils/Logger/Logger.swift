import OSLog

private let kInGameSubsystem = "InGame"

struct Log {
    static let roundStep = Logger(subsystem: kInGameSubsystem, category: "Round step")
    static let collision = Logger(subsystem: kInGameSubsystem, category: "Collision")

    // Don't commit code that uses this debugger. It's should be used only for debugging purposes
    static let nowDebugging = Logger(subsystem: kInGameSubsystem, category: "NewDebugging")
}
