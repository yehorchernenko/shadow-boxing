import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import AVFoundation

fileprivate let kScoreAttachmentID = "ScoreViewAttachment"

struct ImmersiveView: View {
    private let arSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()
    @Environment(GameModel.self) var gameModel
    @State private var collisionSubscription: EventSubscription?
    @State private var sceneSubscription: EventSubscription?
    @State private var sceneSubscription2: EventSubscription?
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    @State var spaceOrigin = Entity()
    @State private var bodyEntity = BodyEntity()

    var body: some View {
        RealityView { content, attachments in
            content.add(spaceOrigin)
            content.add(bodyEntity)
            self.setupScoreAttachment(attachments)

            self.collisionSubscription = content.subscribe(to: CollisionEvents.Began.self, self.handleBodyCollision(event:))

            self.sceneSubscription = content.subscribe(to: SceneEvents.Update.self, self.handleSceneUpdate(event:))

            Task {
                try await self.arSession.run([self.worldTrackingProvider])
            }

        } attachments: {
            Attachment(id: kScoreAttachmentID) {
                InGameView()
            }
        }
        .simulatorOnlyGesture(SpatialTapGesture().targetedToAnyEntity().onEnded({ value in
            self.handleHandCollision(entity: value.entity)
        }))
        .task {
            guard let round = self.gameModel.round else {
                assertionFailure("Round is nil")
                return
            }

            await self.attachTargets(for: round.steps)
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
    // TODO: Replace entity with `event`
    private func handleHandCollision(entity: Entity) {
        guard let targetEntity = entity as? TargetEntity else { return }
        targetEntity.removeFromParent()

        self.gameModel.handlePunch(targetEntity.configuration.punch)

        Log.collision.info("Hand collision: \(entity.name)")
    }

    /// Detects collisions between user body and entities
    private func handleBodyCollision(event: CollisionEvents.Began) {
        // Handle targets collisions with user body
        guard [event.entityA, event.entityB].contains(where: \.isBody) else { return }

        if [event.entityA, event.entityB].contains(where: \.isDodge) {
            self.handleBodyDodgeCollision(event)
        }

        if [event.entityA, event.entityB].contains(where: \.isTarget) {
            self.handleBodyTargetCollision(event)
        }

        Log.collision.info("Body collision: \(event.entityA.name) \(event.entityB.name)")
    }

    private func handleBodyDodgeCollision(_ event: CollisionEvents.Began) {
        // TODO: Update score
        self.bodyEntity.playAudio(Sounds.Punch.missed.audioResource)

        // Remove dodges after collisions
        [event.entityA, event.entityB]
            .compactMap { $0 as? DodgeEntity }
            .forEach { $0.removeFromParent() }
    }

    private func handleBodyTargetCollision(_ event: CollisionEvents.Began) {
        self.bodyEntity.playAudio(Sounds.Punch.straight.audioResource)
        self.gameModel.missedCombo()

        // Remove targets after collisions
        [event.entityA, event.entityB]
            .compactMap { $0 as? TargetEntity }
            .forEach { $0.removeFromParent() }
    }

    /// Moves targets towards user body
    private func handleSceneUpdate(event: SceneEvents.Update) {
        // Movement targets towards user body (device position)
        for movingEntity in self.spaceOrigin.children.compactMap({ $0 as? TargetEntity }) {
            movingEntity.moveWithNoiseTo(self.bodyEntity.position)
        }

        // Movement dodges towards user body (device position)
        for movingEntity in self.spaceOrigin.children.compactMap({ $0 as? DodgeEntity }) {
            movingEntity.moveWithNoiseTo(self.bodyEntity.position)
        }

        // Update body position. Set to device position
        // Note: We use device position instead of tracking AnchorEntity.Head, because
        // AnchorEntity.Head doesn't participate in collisions detection.
        guard let devicePosition = self.worldTrackingProvider
            .queryDeviceAnchor(atTimestamp: Date.now.timeIntervalSince1970) else { return }
        self.bodyEntity.transform = Transform(matrix: devicePosition.originFromAnchorTransform)
    }

    func attachTargets(for steps: [RoundStep]) async {
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

    @MainActor
    func spawnTarget(for punch: Punch) async throws {
        let speed = self.gameModel.round?.level.speed ?? Level.easy.speed
        let target = await TargetEntity(configuration: .init(speed: speed, punch: punch))
        target.position = SIMD3<Float>(0, 1.5, -7)

        self.spaceOrigin.addChild(target)
    }

    @MainActor
    func spawnDodge() async throws {
        let speed = self.gameModel.round?.level.speed ?? Level.easy.speed
        let target = await DodgeEntity(speed: speed)
        target.position = SIMD3<Float>(0, 1.5, -7)

        self.spaceOrigin.addChild(target)
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
