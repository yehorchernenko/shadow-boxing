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
    static var lastLeftHandPosition: SIMD3<Float>?
    static var lastLeftHandMovementDirection = [MovementDirection]()

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
            
            if handComponent.chirality == .left {
                leftHandMovingDirection(handAnchor)
            }

            // Iterate through all of the anchors on the hand skeleton.
            if let handSkeleton = handAnchor.handSkeleton {
                let isFist = self.isFist(handSkeleton)
                for (jointName, jointEntity) in handComponent.fingers {
                    /// The current transform of the person's hand joint.
                    let anchorFromJointTransform = handSkeleton.joint(jointName).anchorFromJointTransform

                    // Update the joint entity to match the transform of the person's hand joint.
                    jointEntity.setTransformMatrix(
                        handAnchor.originFromAnchorTransform * anchorFromJointTransform,
                        relativeTo: nil
                    )

                    // Update joint color based on gesture
                    if let modelEntity = jointEntity as? HandJointEntity {
                        modelEntity.updateColor(isFist: isFist)
                        modelEntity.updateCollisionComponent(isFist: isFist)
                        if handComponent.chirality == .left {
                            modelEntity.setMovementDirection(Self.lastLeftHandMovementDirection)
                        }
                    }
                    
//                    if handComponent.chirality == .left, let modelEntity = jointEntity as? HandJointEntity {
//                        leftHandMovingDirection(handAnchor)
                        
//                    }
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

    func isFist(_ handSkeleton: HandSkeleton) -> Bool {
        let wristPos = SIMD3<Float>(0,0,0)

        let fingertipNames: [HandSkeleton.JointName] = [
            .thumbTip, .indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip
        ]

        let threshold: Float = 0.15 // 1.5 cm

        return fingertipNames.allSatisfy { jointName in
            let tipPos = handSkeleton.joint(jointName).anchorFromJointTransform.columns.3[SIMD3(0, 1, 2)]
            let distance = simd_distance(tipPos, wristPos)
            return distance < threshold
        }
    }
    
    func leftHandMovingDirection(_ handAnchor: HandAnchor) {
        // Get current wrist position from the hand anchor
        let currentPosition = SIMD3<Float>(
            handAnchor.originFromAnchorTransform.columns.3.x,
            handAnchor.originFromAnchorTransform.columns.3.y,
            handAnchor.originFromAnchorTransform.columns.3.z
        )
        
        var currentDirection = [MovementDirection]()
        
        // Check if we have a previous position to compare with
        if let previousPosition = Self.lastLeftHandPosition {
            // Calculate the movement vector
            let movement = currentPosition - previousPosition
            
            // Define threshold to avoid detecting small unintentional movements
            let threshold: Float = 0.005 // 50mm
            
            // Horizontal movement (left/right)
            if abs(movement.x) > threshold {
                let horizontalDirection: MovementDirection = movement.x > 0 ? .right : .left
                currentDirection.append(horizontalDirection)
            }
            
            // Vertical movement (up/down)
            if abs(movement.y) > threshold {
                let verticalDirection: MovementDirection = movement.y > 0 ? .up : .down
                currentDirection.append(verticalDirection)
            }
            
            // Depth movement (forward/backward)
            if abs(movement.z) > threshold {
                // In RealityKit's coordinate system, negative Z is typically forward (toward the user)
                let depthDirection: MovementDirection = movement.z < 0 ? .forward : .backward
                currentDirection.append(depthDirection)
            }
            
            
            Self.lastLeftHandMovementDirection = currentDirection
        }
        
        // Save current position for next frame comparison
        Self.lastLeftHandPosition = currentPosition
    }
}

// Extension for rounding to decimal places
extension Float {
    func rounded(to places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
