/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A component that tracks an entity to a hand.
*/
import RealityKit
import ARKit.hand_skeleton

/// A component that tracks the hand skeleton.
struct HandTrackingComponent: Component {
    /// The chirality for the hand this component tracks.
    let chirality: AnchoringComponent.Target.Chirality

    /// A lookup that maps each joint name to the entity that represents it.
    var fingers: [HandSkeleton.JointName: Entity] = [:]
    
    /// Creates a new hand-tracking component.
    /// - Parameter chirality: The chirality of the hand target.
    init(chirality: AnchoringComponent.Target.Chirality, handTrackingProvider: HandTrackingProvider) {
        self.chirality = chirality
        HandTrackingSystem.handTracking = handTrackingProvider
        HandTrackingSystem.registerSystem()
    }
}

