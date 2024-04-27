import Foundation
import OSLog
import RealityKit

/// Convenience methods for `Entity`.
public extension Entity {
    /// Returns the position of the entity specified in the app's coordinate system. On
    /// iOS and macOS, which don't have a device native coordinate system, scene
    /// space is often referred to as "world space".
    var scenePosition: SIMD3<Float> {
        get { position(relativeTo: nil) }
        set { setPosition(newValue, relativeTo: nil) }
    }
}

extension Entity {
    var isTarget: Bool {
        self.name.contains(ImmersiveConstants.kTargetEntityName)
    }

    var isBody: Bool {
        self.name.contains(ImmersiveConstants.kBodyEntityName)
    }

    var isDodge: Bool {
        self.name.contains(ImmersiveConstants.kDodgeEntityName)
    }

    var isHandJoint: Bool {
        self.name.contains(ImmersiveConstants.kHandJointEntityName)
    }
}
