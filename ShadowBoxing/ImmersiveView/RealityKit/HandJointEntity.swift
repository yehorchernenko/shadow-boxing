import RealityKit
import UIKit
import RealityKitContent

class HandJointEntity: Entity {
    /// Model is visible for users, doesn't participate in collisions
    private let modelEntity: Entity

    required init() {
        self.modelEntity = ModelEntity(mesh: .generateSphere(radius: 0.005),
                                       materials: [SimpleMaterial(color: .blue, isMetallic: false)])


        super.init()

        /// Model is visible for users, doesn't participate in collisions
        self.addChild(self.modelEntity)

        /// Setup collision
        let collisionShape = ShapeResource.generateSphere(radius: 0.005)
        let collisionComponent = CollisionComponent(shapes: [collisionShape])
        self.components.set(collisionComponent)

        self.name = ImmersiveConstants.kHandJointEntityName
    }
}
