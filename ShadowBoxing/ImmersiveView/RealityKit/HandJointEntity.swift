import RealityKit
import UIKit
import RealityKitContent

class HandJointEntity: Entity {
    private static let defaultCollisionComponent: CollisionComponent = {
        let collisionShape = ShapeResource.generateSphere(radius: 0.005)
        return CollisionComponent(shapes: [collisionShape])
    }()
    
    /// Model is visible for users, doesn't participate in collisions
    private let modelEntity: ModelEntity

    required init() {
        self.modelEntity = ModelEntity(mesh: .generateSphere(radius: 0.01),
                                       materials: [SimpleMaterial(color: .white, isMetallic: false)])


        super.init()

        /// Model is visible for users, doesn't participate in collisions\
        self.addChild(self.modelEntity)

        /// Setup collision
        self.components.set(Self.defaultCollisionComponent)

        self.name = ImmersiveConstants.kHandJointEntityName
    }
    
    func updateColor(isFist: Bool) {
        let material = SimpleMaterial(color: isFist ? .white : .red, isMetallic: false)
        modelEntity.model?.materials = [material]
    }
    
    func updateCollisionComponent(isFist: Bool) {
        if isFist {
            self.components.set(Self.defaultCollisionComponent)
        } else {
            self.components.remove(CollisionComponent.self)
        }
    }
}
