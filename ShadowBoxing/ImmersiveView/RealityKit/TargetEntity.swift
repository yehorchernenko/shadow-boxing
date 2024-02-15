import RealityKit
import UIKit

class TargetEntity: Entity {
    /// Target is visible for users, doesn't participate in collisions
    private let modelEntity: ModelEntity
    private let configuration: TargetEntityConfiguration

    /// Noise required to simulate punches that goes to different parts of the body
    /// The of noise is a bit less than body size, to ensure that the punch will hit the body
    private let positionNoise = SIMD3<Float>(
        .random(in: -0.45...0.45),
        .random(in: -0.45...0.45),
        .random(in: -0.45...0.45)
    )

    init(configuration: TargetEntityConfiguration) {
        self.configuration = configuration
        let mesh = MeshResource.generateSphere(radius: 0.3)
        let mat = SimpleMaterial(color: configuration.hand.targetColor, isMetallic: false)
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
    
    required init() {
        // for some reason it's called on collisions
        print("init TargetEntity with default configuration.")
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
}

struct TargetEntityConfiguration {
    let speed: Float
    let hand: Hand

    static let invalid = TargetEntityConfiguration(speed: 0, hand: .left)
}


extension Hand {
    var targetColor: UIColor {
        switch self {
        case .left:
            return .systemRed
        case .right:
            return .systemGreen
        }
    }
}
