import RealityKit

class BodyEntity: Entity {
    /// The body of the user. Visual representation of the user's body. Visible only in debug.
    /// Doesn't participate in collisions.
    private let modelEntity: ModelEntity?

    required init() {
        let bodyMesh = MeshResource.generateBox(size: 0.5)
        let bodyModel = ModelEntity(mesh: bodyMesh, materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        self.modelEntity = bodyModel

        super.init()

        /// User body shape, not visible, participates in collisions
        let collisionShape = ShapeResource.generateBox(width: 0.5, height: 0.5, depth: 0.5)
        let collisionComponent = CollisionComponent(shapes: [collisionShape])
        self.components.set(collisionComponent)

        self.name = ImmersiveConstants.kBodyEntityName
    }
}
