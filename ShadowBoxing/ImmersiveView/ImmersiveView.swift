//
//  ImmersiveView.swift
//  ShadowBoxing
//
//  Created by Yehor Chernenko on 21.01.2024.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import AVFoundation

/// A hand-picked selection of random starting parameters for the motion of the clouds.
let targetPaths: [(Double, Double, Double)] = [
    (x: 1.757_231_498_429_01, y: 1.911_673_694_896_59, z: -8.094_368_331_589_704),
    (x: -0.179_269_237_592_594_17, y: 1.549_268_306_906_908_4, z: -7.254_713_426_424_875),
    (x: -0.013_296_800_013_828_491, y: 2.147_766_026_068_617_8, z: -8.601_541_438_900_849),
    (x: 2.228_704_746_539_703, y: 0.963_797_733_336_365_2, z: -7.183_621_312_117_454),
    (x: -0.163_925_123_812_864_4, y: 1.821_619_897_406_197, z: -8.010_893_563_433_282),
    (x: 0.261_716_575_589_896_03, y: 1.371_932_443_334_715, z: -7.680_206_361_333_17),
    (x: 1.385_410_631_256_254_6, y: 1.797_698_998_556_775_5, z: -7.383_548_882_448_866),
    (x: -0.462_798_470_454_367_4, y: 1.431_650_092_907_264_4, z: -7.169_154_476_151_876),
    (x: 1.112_766_805_791_563, y: 0.859_548_406_627_492_2, z: -7.147_229_496_720_969),
    (x: 1.210_194_536_657_374, y: 0.880_254_638_358_228_8, z: -8.051_132_737_691_349),
    (x: 0.063_637_772_899_141_52, y: 1.973_172_635_040_014_7, z: -8.503_837_407_474_947),
    (x: 0.883_082_630_134_997_2, y: 1.255_268_496_843_653_4, z: -7.760_994_300_660_705),
    (x: 0.891_719_821_716_725_7, y: 2.085_000_111_104_786_7, z: -8.908_048_018_555_112),
    (x: 0.422_260_067_132_894_2, y: 1.370_335_319_771_187, z: -7.525_853_388_894_509),
    (x: 0.473_470_811_107_753_46, y: 1.864_930_149_962_240_6, z: -8.164_641_191_459_626)
]

struct TargetSpawnParameters {
    static var deltaX = 0.02
    static var deltaY = -0.12
    static var deltaZ = 7.0

    static var speed = 11.73
}

let spaceOrigin = Entity()
var targetPathsIndex = 0
var targetMovementAnimations = [AnimationResource]()

fileprivate let kScoreAttachmentID = "ScoreViewAttachment"
fileprivate let kBodyEntityName = "Body"

struct ImmersiveView: View {
    private let arSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()
    @State private var collisionSubscription: EventSubscription?
    @State private var sceneSubscription: EventSubscription?
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    @State private var bodyEntity: Entity = {
        let bodyMesh = MeshResource.generateSphere(radius: 0.2)
        let bodyModel = ModelEntity(mesh: bodyMesh, materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        bodyModel.name = kBodyEntityName

        #if targetEnvironment(simulator)
            // Collision shape a bit bigger for debug purpose
            let collisionShape = ShapeResource.generateSphere(radius: 0.22)
            let collisionComponent = CollisionComponent(shapes: [collisionShape])
            bodyModel.components.set(collisionComponent)
        #else
            bodyModel.generateCollisionShapes(recursive: false)
        #endif

        return bodyModel
    }()

    var body: some View {
        RealityView { content, attachments in
            content.add(spaceOrigin)
            content.add(bodyEntity)
            self.setupScoreAttachment(attachments)

            self.collisionSubscription = content.subscribe(to: CollisionEvents.Began.self, self.handleCollision(event:))

            self.sceneSubscription = content.subscribe(to: SceneEvents.Update.self, self.handleSceneUpdate(event:))

            Task {
                try await self.arSession.run([worldTrackingProvider])
            }

        } attachments: {
            Attachment(id: kScoreAttachmentID) {
                InGameView()
            }
        }
        .onAppear {
            self.generateTargetMovementAnimations()
        }
        .onReceive(timer) { _ in
            Task { @MainActor in
                do {
                    let spawnAmount = 3
                    for _ in (0..<spawnAmount) {
                        _ = try await spawnTarget()
                        try await Task.sleep(for: .milliseconds(.random(in: 800...1500)))
                    }
                } catch {

                }
            }
        }
    }

    private func setupScoreAttachment(_ attachments: RealityViewAttachments) {
        if let scoreView = attachments.entity(for: kScoreAttachmentID) {
            scoreView.position = simd_float3(-0.5,1,-1)
            scoreView.components.set(BillboardComponent())
            spaceOrigin.addChild(scoreView)
        }
    }

    private func handleCollision(event: CollisionEvents.Began) {
        if event.entityA.name == kBodyEntityName || event.entityB.name == kBodyEntityName {
            print("\(event.entityA.name) \(event.entityB.name)")
            bodyEntity.playAudio(Sounds.Punch.missed.audioResource)
        }
    }

    private func handleSceneUpdate(event: SceneEvents.Update) {
        // Update body position. Set to device position
        guard let devicePosition = self.worldTrackingProvider
            .queryDeviceAnchor(atTimestamp: Date.now.timeIntervalSince1970) else { return }
        self.bodyEntity.transform = Transform(matrix: devicePosition.originFromAnchorTransform)
    }

    @MainActor
    func spawnTarget() async throws -> Entity {
        let start = Point3D(
            x: targetPaths[targetPathsIndex].0,
            y: targetPaths[targetPathsIndex].1,
            z: targetPaths[targetPathsIndex].2
        )

        let cloud = try await spawnTargetExact(
            start: start,
            end: .init(
                x: start.x + TargetSpawnParameters.deltaX,
                y: start.y + TargetSpawnParameters.deltaY,
                z: start.z + TargetSpawnParameters.deltaZ
            ),
            speed: TargetSpawnParameters.speed
        )

        // Needs to increment *after* spawnCloudExact()
        targetPathsIndex += 1
        targetPathsIndex %= targetPaths.count

//        cloudEntities.append(cloud)
        return cloud
    }

    @MainActor
    func spawnTargetExact(start: Point3D, end: Point3D, speed: Double) async throws -> Entity {
        // Add the initial RealityKit content
//        guard let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle)
//        else { fatalError("No target template") }

//        cloud.generateCollisionShapes(recursive: true)

        let mesh = MeshResource.generateBox(width: 0.5, height: 0.5, depth: 0.5)
        let mat = SimpleMaterial(color: .systemPink, isMetallic: false)

        let target = ModelEntity(mesh: mesh, materials: [mat])
        target.name = "Target"
        target.position = simd_float(start.vector + .init(x: 0, y: 0, z: -0.7))
        target.generateCollisionShapes(recursive: false)

        let animation = targetMovementAnimations[targetPathsIndex]

        target.playAnimation(animation, transitionDuration: 1.0, startsPaused: false)

        spaceOrigin.addChild(target)

        return target
    }

    /// Preload animation assets.
    func generateTargetMovementAnimations() {
        for index in (0..<targetPaths.count) {
            let start = Point3D(
                x: targetPaths[index].0,
                y: targetPaths[index].1,
                z: targetPaths[index].2
            )
            let end = Point3D(
                x: start.x + TargetSpawnParameters.deltaX,
                y: start.y + TargetSpawnParameters.deltaY,
                z: start.z + TargetSpawnParameters.deltaZ
            )
            let speed = TargetSpawnParameters.speed

            let line = FromToByAnimation<Transform>(
                name: "line",
                from: Transform(translation: simd_float(start.vector)),
                to: Transform(translation: simd_float(end.vector)),
                duration: speed,
                bindTarget: .transform
            )

            let animation = try! AnimationResource
                .generate(with: line)

            targetMovementAnimations.append(animation)
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
