import RealityKit

class TargetEntity: Entity {
    /// Target is visible for users, doesn't participate in collisions
    private let modelEntity: ModelEntity

    /// Noise required to simulate punches that goes to different parts of the body
    /// The of noise is a bit less than body size, to ensure that the punch will hit the body
    let positionNoise = SIMD3<Float>(
        .random(in: -0.45...0.45),
        .random(in: -0.45...0.45),
        .random(in: -0.45...0.45)
    )

    required init() {
        let mesh = MeshResource.generateSphere(radius: 0.3)
        let mat = SimpleMaterial(color: .systemPink, isMetallic: false)
        let target = ModelEntity(mesh: mesh, materials: [mat])
        self.modelEntity = target

        super.init()

        /// Target is visible for users, doesn't participate in collisions
        self.addChild(target)

        /// Setup collision
        let collisionShape = ShapeResource.generateSphere(radius: 0.3)
        let collisionComponent = CollisionComponent(shapes: [collisionShape])
        self.components.set(collisionComponent)

        self.name = ImmersiveConstants.kTargetEntityName
    }

    /// Moves the target to the given position with noise
    func moveWithNoiseTo(_ toPosition: SIMD3<Float>) {
        let toEntityPosition = toPosition + self.positionNoise
        let directionVector = normalize(toEntityPosition - self.position)
        let speed: Float = 0.01 // Adjust speed as needed
        self.position += directionVector * speed
    }
}
