import RealityKit
import UIKit
import RealityKitContent

class DodgeEntity: Entity {
    /// Target is visible for users, doesn't participate in collisions
    private let modelEntity: Entity
    private let speed: Float

    /// Noise required to simulate punches that goes to different parts of the body
    /// The of noise is a bit less than body size, to ensure that the punch will hit the body
    private let positionNoise = SIMD3<Float>(0, 0, 0)

    init(speed: Float) async {
        self.modelEntity = await Self.loadFromRealityComposerScene("dodge")
        self.speed = speed
        
        super.init()

        /// Target is visible for users, doesn't participate in collisions
        self.addChild(self.modelEntity)

        /// Setup collision
        let collisionShape = ShapeResource.generateSphere(radius: 0.3)
        let collisionComponent = CollisionComponent(shapes: [collisionShape])
        self.components.set(collisionComponent)

        self.name = ImmersiveConstants.kDodgeEntityName
    }

    required init() {
        // for some reason it's called on collisions
        print("init TargetEntity with default configuration.")
        self.modelEntity = ModelEntity()
        self.speed = 0.01
        super.init()
    }

    /// Moves the target to the given position with noise
    func moveWithNoiseTo(_ toPosition: SIMD3<Float>) {
        let toEntityPosition = toPosition + self.positionNoise
        let directionVector = normalize(toEntityPosition - self.position)
        self.position += directionVector * self.speed
    }

    static func loadFromRealityComposerScene(_ name: String) async -> Entity {
        let scene = try? await Entity(named: name, in: realityKitContentBundle)
        //if let entity = scene?.findEntity(named: configuration.punch.entityName)?.clone(recursive: true)
        if let entity = scene  {
            return entity
        } else {
            let mesh = MeshResource.generateSphere(radius: 0.3)
            let mat = SimpleMaterial(color: .blue, isMetallic: false)
            let target = ModelEntity(mesh: mesh, materials: [mat])
            return target
        }
    }
}
