import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import AVFoundation

fileprivate let kScoreAttachmentID = "ScoreViewAttachment"

struct ImmersiveView: View {
    private let arSession = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()
    private let worldTrackingProvider = WorldTrackingProvider()
    @Environment(GameModel.self) var gameModel
    @State private var collisionSubscription: EventSubscription?
    @State private var sceneSubscription: EventSubscription?
    @State private var feedbackEntity: Entity?

    @State var spaceOrigin = Entity()
    @State private var bodyEntity = BodyEntity()

    var body: some View {
        RealityView { content, attachments in
            content.add(spaceOrigin)
            content.add(bodyEntity)
            self.attachHandEntities(content)
            
            self.setupScoreAttachment(attachments)

            self.collisionSubscription = content.subscribe(to: CollisionEvents.Began.self, self.handleCollision(event:))
            self.sceneSubscription = content.subscribe(to: SceneEvents.Update.self, self.handleSceneUpdate(event:))

            Task {
                HandTrackingSystem.handTracking = self.handTrackingProvider
                try await self.arSession.run(self.environmentBasedProviders)
            }

        } attachments: {
            Attachment(id: kScoreAttachmentID) {
                InGameView()
            }
        }
        .simulatorOnlyGesture(SpatialTapGesture().targetedToAnyEntity().onEnded({ value in
            self.simulateHandJointPosition(at: value.entity.position)
        }))
        .upperLimbVisibility(.visible)
        .task {
            guard let round = self.gameModel.round else {
                assertionFailure("Round is nil")
                return
            }

            await self.attachTargets(for: round.steps)
//            self.attachHandEntities()
        }
    }

    private func setupScoreAttachment(_ attachments: RealityViewAttachments) {
        if let scoreView = attachments.entity(for: kScoreAttachmentID) {
            scoreView.position = simd_float3(-0.5,1,-1)
            scoreView.components.set(BillboardComponent())
            spaceOrigin.addChild(scoreView)
        }
    }

    // Detects collisions between user hands and targets
    private func handleHandTargetCollision(_ event: CollisionEvents.Began) {
        guard let targetEntity = event.entity(of: TargetEntity.self),
              !targetEntity.shouldIgnoreCollision,
              let handJointEntity = event.entity(of: HandJointEntity.self) else { return }
        
        // Extract needed information
        let punch = targetEntity.configuration.punch
        let handChirality = handJointEntity.chirality
        let movements = handJointEntity.movementDirection
        
        // Check if the hand matches the punch's expected hand
        let isCorrectHand = (punch.hand == .left && handChirality == .left) || 
                           (punch.hand == .right && handChirality == .right)
        
        if !isCorrectHand {
            // Wrong hand feedback
            showFeedbackText("Wrong hand!", color: .red)
            return // Wrong hand, don't handle collision
        }
        
        // Check if movement pattern matches expected punch type
        let isCorrectMovement = matchesExpectedMovement(movements: movements, punchKind: punch.kind)
        
        if !isCorrectMovement {
            // Wrong movement feedback
            showFeedbackText("Wrong punch!", color: .red)
            return // Wrong movement, don't handle collision
        }
        
        // All conditions met, handle the collision
        self.bodyEntity.playAudio(Sounds.Punch.hit.audioResource)
        self.gameModel.handlePunch(targetEntity.configuration.punch)

        let animationDuration = 0.3
        targetEntity.playSqueezeAnimation(duration: animationDuration)
        // Prevent further collisions with the same target.
        // Produces crash - targetEntity.components.remove(CollisionComponent.self)
        // Use a flag to ignore collisions instead.
        targetEntity.shouldIgnoreCollision = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(animationDuration * 1_000_000_000))
            targetEntity.removeFromParent()

            #if targetEnvironment(simulator)
            handJointEntity.removeFromParent()
            #endif
        }

        Log.collision.info("Hand collision: \(targetEntity.name)")
    }
    
    /// Shows immersive 3D text feedback in the scene
    private func showFeedbackText(_ message: String, color: UIColor) {
        // Remove any existing feedback entity
        feedbackEntity?.removeFromParent()
        
        // Create text mesh with the feedback message
        let textMesh = MeshResource.generateText(
            message,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1, weight: .bold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        // Create material with the specified color
        let material = SimpleMaterial(color: color, isMetallic: false)
        
        // Create model entity with the text mesh and material
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        
        // Position the text in front of the user
        textEntity.position = SIMD3<Float>(0, 1.5, -1)
        
        // Add billboard component to make text always face the user
        textEntity.components.set(BillboardComponent())
        
        // Store reference to the feedback entity
        feedbackEntity = textEntity
        
        // Add to the scene
        spaceOrigin.addChild(textEntity)
        
        // Hide feedback after delay
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(1.5 * 1_000_000_000)) // 1.5 seconds
            textEntity.removeFromParent()
            if feedbackEntity == textEntity {
                feedbackEntity = nil
            }
        }
    }
    
    /// Determines if the movement pattern matches the expected punch type
    private func matchesExpectedMovement(movements: [MovementDirection], punchKind: Punch.Kind) -> Bool {
        switch punchKind {
        case .jab:
            // Jab is primarily a forward movement
            return movements.contains(.forward)
            
        case .cross:
            // Cross is also primarily a forward movement, just with the rear hand
            return movements.contains(.forward)
            
        case .hook:
            // Left hand hook: primarily left movement, possibly with upward/forward component
            // Right hand hook: primarily right movement, possibly with upward/forward component
            return movements.contains(.left) || movements.contains(.right)
            
        case .uppercut:
            // Uppercut is primarily an upward movement
            return movements.contains(.up)
        }
    }

    /// Detects collisions between user body and entities
    private func handleCollision(event: CollisionEvents.Began) {
        let participants = [event.entityA, event.entityB]

        // Handle targets collisions with user body
        if participants.contains(where: \.isBody) {
            if participants.contains(where: \.isDodge) {
                self.handleBodyDodgeCollision(event)
            }

            if participants.contains(where: \.isTarget) {
                self.handleBodyTargetCollision(event)
            }
        }

        if participants.contains(where: \.isHandJoint) {
            if participants.contains(where: \.isTarget) {
                self.handleHandTargetCollision(event)
            }
        }

        Log.collision.info("Body collision: \(event.entityA.name) \(event.entityB.name)")
    }

    private func handleBodyDodgeCollision(_ event: CollisionEvents.Began) {
        self.gameModel.missedCombo()

        // Remove dodges after collisions
        [event.entityA, event.entityB]
            .compactMap { $0 as? DodgeEntity }
            .forEach { $0.removeFromParent() }
    }

    private func handleBodyTargetCollision(_ event: CollisionEvents.Began) {
        guard let targetEntity = event.entity(of: TargetEntity.self),
              !targetEntity.shouldIgnoreCollision else {
            return
        }

        self.gameModel.missedCombo()

        // Remove targets after collisions
        targetEntity.removeFromParent()
    }

    /// Moves targets towards user body
    private func handleSceneUpdate(event: SceneEvents.Update) {
        // Movement targets towards user body (device position)
        for movingEntity in self.spaceOrigin.children.compactMap({ $0 as? TargetEntity }) {
            var targetPosition = self.bodyEntity.position
            // Make targets lower
            targetPosition.y -= Constants.saved.targetUserHeightOffest
            movingEntity.moveWithNoiseTo(self.bodyEntity.position)
        }

        // Movement dodges towards user body (device position)
        for movingEntity in self.spaceOrigin.children.compactMap({ $0 as? DodgeEntity }) {
            movingEntity.moveTo(self.bodyEntity.position)
            if movingEntity.isPositionReached(self.bodyEntity.position) {
                self.bodyEntity.playAudio(Sounds.Dodge.missed.audioResource)
                movingEntity.removeFromParent()
            }
        }

        // Update body position. Set to device position
        // Note: We use device position instead of tracking AnchorEntity.Head, because
        // AnchorEntity.Head doesn't participate in collisions detection.
        guard let deviceAnchor = self.worldTrackingProvider
            .queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }
        self.bodyEntity.transform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
    }

    private func attachTargets(for steps: [RoundStep]) async {
        for step in steps {
            switch step {
            case .delay(let milliseconds):
                Log.roundStep.info("Delay: \(milliseconds) ms")
                try? await Task.sleep(for: .milliseconds(milliseconds))
            case .punch(let punch):
                try? await self.spawnTarget(for: punch)
                Log.roundStep.info("Punch: \(punch.kind.rawValue) with \(punch.hand.rawValue) hand")
            case .combo(let combo):
                Log.roundStep.info("Combo start \(combo.id)")
                await self.attachTargets(for: combo.steps)
            case .dodge:
                Log.roundStep.info("Dodge")
                try? await self.spawnDodge()
            }
        }

        Log.roundStep.info("Round duration: \(steps.duration) ms")
    }

    private func attachHandEntities(_ content: RealityViewContent) {
        #if !targetEnvironment(simulator)
        // Add the left hand.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left, handTrackingProvider: self.handTrackingProvider))
        content.add(leftHand)

        // Add the right hand.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right, handTrackingProvider: self.handTrackingProvider))
        content.add(rightHand)

        #endif
    }

    @MainActor
    func spawnTarget(for punch: Punch) async throws {
        let speed = self.gameModel.round?.level.speed ?? Level.easy.speed
        let target = await TargetEntity(configuration: .init(speed: speed, punch: punch))
        target.position = SIMD3<Float>(0, 
                                       Float(Constants.saved.targetEntitySpawnHeight),
                                       Float(Constants.saved.targetEntitySpawnDistance))

        self.spaceOrigin.addChild(target)
    }

    @MainActor
    func spawnDodge() async throws {
        let speed = self.gameModel.round?.level.speed ?? Level.easy.speed
        let target = await DodgeEntity(speed: speed)
        target.position = SIMD3<Float>(0,
                                       Float(Constants.saved.dodgeEntitySpawnHeight),
                                       Float(Constants.saved.dodgeEntitySpawnDistance))

        self.spaceOrigin.addChild(target)
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}


extension ImmersiveView {
    var environmentBasedProviders: [DataProvider] {
        #if targetEnvironment(simulator)
        return [self.worldTrackingProvider]
        #else
        return [self.worldTrackingProvider, self.handTrackingProvider]
        #endif
    }

    func simulateHandJointPosition(at position: SIMD3<Float>) {
        let handJoint = HandJointEntity()
        handJoint.position = position
        handJoint.position.z += 0.5
        self.spaceOrigin.addChild(handJoint)
    }
}
