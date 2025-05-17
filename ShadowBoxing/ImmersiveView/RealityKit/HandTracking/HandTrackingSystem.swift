/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A system that updates entities that have hand-tracking components.
*/
import RealityKit
import ARKit

/// A system that provides hand-tracking capabilities.
struct HandTrackingSystem: System {
    /// The provider instance for hand-tracking.
    static var handTracking: HandTrackingProvider!
    
    /// The most recent anchor that the provider detects on the left hand.
    static var latestLeftHand: HandAnchor?

    /// The most recent anchor that the provider detects on the right hand.
    static var latestRightHand: HandAnchor?

    init(scene: RealityKit.Scene) {
        Task { await Self.runTracking() }
    }

    @MainActor
    static func runTracking() async {
        // Start to collect each hand-tracking anchor.
        for await anchorUpdate in handTracking.anchorUpdates {
            // Check whether the anchor is on the left or right hand.
            switch anchorUpdate.anchor.chirality {
            case .left:
                self.latestLeftHand = anchorUpdate.anchor
            case .right:
                self.latestRightHand = anchorUpdate.anchor
            }
        }
    }
    
    /// The query this system uses to find all entities with the hand-tracking component.
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    /// Performs any necessary updates to the entities with the hand-tracking component.
    /// - Parameter context: The context for the system to update.
    func update(context: SceneUpdateContext) {
        let handEntities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in handEntities {
            guard var handComponent = entity.components[HandTrackingComponent.self] else { continue }

            // Set up the finger joint entities if you haven't already.
            if handComponent.fingers.isEmpty {
                self.addJoints(to: entity, handComponent: &handComponent)
            }

            // Get the hand anchor for the component, depending on its chirality.
            guard let handAnchor: HandAnchor = switch handComponent.chirality {
                case .left: Self.latestLeftHand
                case .right: Self.latestRightHand
                default: nil
            } else { continue }

            // Iterate through all of the anchors on the hand skeleton.
            if let handSkeleton = handAnchor.handSkeleton {
                for (jointName, jointEntity) in handComponent.fingers {
                    /// The current transform of the person's hand joint.
                    let anchorFromJointTransform = handSkeleton.joint(jointName).anchorFromJointTransform

                    // Update the joint entity to match the transform of the person's hand joint.
                    jointEntity.setTransformMatrix(
                        handAnchor.originFromAnchorTransform * anchorFromJointTransform,
                        relativeTo: nil
                    )
                }
            }
        }
    }
    
    /// Performs any necessary setup to the entities with the hand-tracking component.
    /// - Parameters:
    ///   - entity: The entity to perform setup on.
    ///   - handComponent: The hand-tracking component to update.
    func addJoints(to handEntity: Entity, handComponent: inout HandTrackingComponent) {            
        // For each joint, create a sphere and attach it to the fingers.
        for bone in HandJointsMap.joints {
            // Add a duplication of the sphere entity to the hand entity.
            let newJoint = HandJointEntity() //sphereEntity.clone(recursive: false)
            handEntity.addChild(newJoint)

            // Attach the sphere to the finger.
            handComponent.fingers[bone.0] = newJoint
        }

        // Apply the updated hand component back to the hand entity.
        handEntity.components.set(handComponent)
    }
}
