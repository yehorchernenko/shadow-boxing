import RealityKit
import UIKit
import RealityKitContent

class DodgeEntity: Entity {
    /// Target is visible for users, doesn't participate in collisions
    private let modelEntity: Entity
    private let speed: Float

    init(speed: Float) async {
        self.modelEntity = await Self.loadFromRealityComposerScene("dodge")
        self.speed = speed
        
        super.init()

        /// Target is visible for users, doesn't participate in collisions
        self.addChild(self.modelEntity)

        /// Setup collision
        let collisionShape = ShapeResource.generateBox(width: 1.25, height: 0.25, depth: 0.25)
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
    func moveTo(_ toPosition: SIMD3<Float>) {
        Log.nowDebugging.debug("Dodge position: \(self.position)")
        
        // Height position shouldn't changed because it gives user ability to dodge the entity
        var targetPosition = toPosition
        targetPosition.y = 1.5
        let directionVector = normalize(targetPosition - self.position)
        self.position += directionVector * self.speed
    }

    func isPositionReached(_ position: SIMD3<Float>) -> Bool {
        /// Distance 2D is used because we don't want to check height
        let distance2D = simd_distance(simd_float2(self.position.x, self.position.z), simd_float2(position.x, position.z))
        Log.nowDebugging.debug("Distance: \(distance2D)")

        /// 0.15 (15 cm) is a threshold for position reached
        return distance2D < 0.015
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
