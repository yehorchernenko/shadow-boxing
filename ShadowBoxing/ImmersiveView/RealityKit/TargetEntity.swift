import RealityKit
import UIKit
import RealityKitContent

class TargetEntity: Entity {
    let configuration: TargetEntityConfiguration
    var shouldIgnoreCollision = false
    /// Model is visible for users, doesn't participate in collisions
    private let modelEntity: Entity

    /// Noise required to simulate punches that goes to different parts of the body
    /// The of noise is a bit less than body size, to ensure that the punch will hit the body
    private let positionNoise = SIMD3<Float>(
        .random(in: -0.45...0.45),
        .random(in: -0.45...0.45),
        0 // This coordinate shouldn't have noise to avoid overlaps
    )

    init(configuration: TargetEntityConfiguration) async {
        self.configuration = configuration
        self.modelEntity = await Self.loadFromRealityComposerScene(configuration)

        super.init()

        /// Model is visible for users, doesn't participate in collisions
        self.addChild(self.modelEntity)

        /// Setup collision
        let collisionShape = ShapeResource.generateSphere(radius: 0.3)
        let collisionComponent = CollisionComponent(shapes: [collisionShape])
        self.components.set(collisionComponent)
        self.components.set(InputTargetComponent())

        self.name = ImmersiveConstants.kTargetEntityName
    }
    
    required init() {
        // for some reason it's called on collisions
        self.modelEntity = ModelEntity()
        self.configuration = .invalid
        super.init()
    }
    
    /// Moves the target to the given position with noise
    func moveWithNoiseTo(_ toPosition: SIMD3<Float>) {
        let toEntityPosition = toPosition + self.positionNoise
        let directionVector = normalize(toEntityPosition - self.position)
        let speed: Float = self.configuration.speed
        self.position += directionVector * speed
    }

    func playSqueezeAnimation(duration: TimeInterval) {
        guard let orbitEntity = self.findEntity(named: "orbit") else {
            assertionFailure("Target doesn't have orbit entity")
            return
        }

        var transform = orbitEntity.transform
        transform.scale = [0.3, 0.3, 0.3]
        let animationDefinition = FromToByAnimation(to: transform, duration: duration, timing: .easeIn, bindTarget: .transform)
        let animationViewDefinition = AnimationView(source: animationDefinition)
        let animationResource = try! AnimationResource.generate(with: animationViewDefinition)
        orbitEntity.playAnimation(animationResource)
    }

    static func loadFromRealityComposerScene(_ configuration: TargetEntityConfiguration) async -> Entity {
        let scene = try? await Entity(named: configuration.punch.entityName, in: realityKitContentBundle)
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

struct TargetEntityConfiguration {
    let speed: Float
    let punch: Punch

    static let invalid = TargetEntityConfiguration(speed: 0, punch: Punch(kind: .jab, hand: .left, comboID: nil))
}

extension Punch {
    var entityName: String {
        "\(self.hand.rawValue)_\(self.kind.rawValue)"
    }
}
