# Building an Immersive Boxing Game for Apple Vision Pro - Part 1: Immersion and AR

In this first article of a two-part series, we'll explore how to build an immersive boxing game for Apple Vision Pro inspired by Beat Saber. This project combines hand tracking, spatial awareness, and RealityKit to create a fitness experience where players punch targets in 3D space.

## Overview

Shadow Boxing is a fitness game that challenges players to hit various targets using different boxing techniques. The game tracks player movements in real-time using Apple Vision Pro's hand tracking capabilities and provides scoring based on timing and accuracy.

The immersive experience is built on several key AR components:
- Hand tracking for detecting punches
- Spatial positioning of targets
- Collision detection between hands and targets
- Realistic visual feedback and sound effects

## Technical Architecture

The app is structured using SwiftUI and RealityKit, with clear separation between the immersive components and game logic:

```
ShadowBoxing/
├── ImmersiveView/          # AR components
│   ├── ImmersiveView.swift # Main immersive view
│   └── RealityKit/         # RealityKit entities and components
├── Logic/                  # Game logic
├── UI/                     # UI components
└── ShadowBoxingApp.swift   # Main app
```

## Building the Immersive Experience

### The ImmersiveView

The core of our AR experience is the `ImmersiveView`, which manages:
- AR session setup
- Hand tracking
- World tracking
- Collision detection
- Target spawning and movement

Here's how we initialize the AR session with hand and world tracking:

```swift
private let arSession = ARKitSession()
private let handTrackingProvider = HandTrackingProvider()
private let worldTrackingProvider = WorldTrackingProvider()

// In the RealityView:
Task {
    try await self.arSession.run(self.environmentBasedProviders)
    await self.processHandUpdates()
}
```

### Hand Tracking

One of the most crucial aspects of our game is tracking the player's hands to detect punches. We use Apple's `HandTrackingProvider` to monitor the position of key hand joints:

```swift
private func processHandUpdates() async {
    for await update in self.handTrackingProvider.anchorUpdates {
        let handAnchor = update.anchor
        guard handAnchor.isTracked else { continue }

        // Update positions for each joint
        let start = handAnchor.chirality == .left ? 0 : handJoints.count
        for i in 0..<handJoints.count {
            guard let position = handAnchor.handSkeleton?.joint(handJoints[i]) else { continue }
            let worldPos = handAnchor.originFromAnchorTransform * position.anchorFromJointTransform
            self.handJointEntities[i + start].setTransformMatrix(worldPos, relativeTo: nil)
        }
    }
}
```

We track 16 key hand joints for each hand, including knuckles, finger joints, and wrists, providing precise detection for different punch types.

#### Selecting the Right Hand Joints

For a boxing game, not all hand joints are equally important. We carefully selected the most relevant joints for collision detection:

```swift
let handJoints: [HandSkeleton.JointName] = [
    .thumbIntermediateBase, .indexFingerIntermediateBase, .middleFingerIntermediateBase, .ringFingerIntermediateBase, .littleFingerIntermediateBase,
    .thumbKnuckle, .indexFingerKnuckle, .middleFingerKnuckle, .ringFingerKnuckle, .littleFingerKnuckle,
    .indexFingerMetacarpal, .middleFingerMetacarpal, .ringFingerMetacarpal, .littleFingerMetacarpal,
    .wrist, .forearmWrist,
]
```

This comprehensive set of joint tracking provides coverage across the hand for collision detection with targets. Currently, the game doesn't analyze hand movements to determine which type of punch the player is performing. Instead, each target has a predefined punch type associated with it (jab, cross, hook, etc.), and the player is expected to perform that specific punch when hitting the target.

In future iterations, we plan to implement punch type detection by analyzing:
- Relative positions of knuckles and wrist joints
- Velocity and direction of movement
- Hand orientation during impact

This would allow for more sophisticated gameplay where players could choose which type of punch to throw, rather than following predefined patterns.

#### Creating Visual Representations

Each tracked joint is represented by a `HandJointEntity` in our 3D space. These entities serve two critical purposes:

1. **Collision Detection**: They are the physical points that interact with target entities
2. **Visual Feedback**: In development mode, they can be visualized to help debug and refine tracking

```swift
private func attachHandEntities() {
    #if !targetEnvironment(simulator)
    self.handJointEntities.forEach { self.spaceOrigin.addChild($0) }
    #endif
}
```

For simulator testing, we implemented a workaround that simulates hand positions when tapping in the 3D space:

```swift
.simulatorOnlyGesture(SpatialTapGesture().targetedToAnyEntity().onEnded({ value in
    self.simulateHandJointPosition(at: value.entity.position)
}))
```

#### Handling Left vs Right Hand

Distinguishing between left and right hands is crucial for our game, as different punches are performed with specific hands. The `HandTrackingProvider` gives us this information through the `chirality` property:

```swift
// Update ball positions for each joint. If it's the left hand, start at 0, if it's the right hand, start at 16.
let start = handAnchor.chirality == .left ? 0 : handJoints.count
```

This strategy allows us to maintain a single array of hand joint entities while still differentiating between hands, simplifying our collision detection logic.

#### Real-time Tracking Challenges

Implementing hand tracking for a high-speed activity like boxing presented several challenges:

1. **Tracking Latency**: Boxing movements are fast, so minimizing the delay between physical movement and digital representation was essential. We optimized our update loop to prioritize hand position updates.

2. **Tracking Reliability**: Rapid movements can cause tracking to fail temporarily. Our code includes guards to handle situations where joints aren't tracked:

   ```swift
   guard handAnchor.isTracked else { continue }
   guard let position = handAnchor.handSkeleton?.joint(handJoints[i]) else { continue }
   ```

3. **Occlusion Handling**: When hands move behind each other or outside the field of view, tracking can be lost. We implemented prediction algorithms to maintain approximate hand positions during brief tracking losses.

4. **Power Consumption**: Continuous high-frequency hand tracking is power-intensive. We carefully balanced update frequency with battery efficiency by optimizing our tracking loop.

#### Transforming to World Space

A critical aspect of hand tracking is correctly transforming joint positions from the anchor's local space to world space. This transformation ensures that hand joints are correctly positioned relative to targets and other game elements:

```swift
let worldPos = handAnchor.originFromAnchorTransform * position.anchorFromJointTransform
self.handJointEntities[i + start].setTransformMatrix(worldPos, relativeTo: nil)
```

This transformation pipeline allows for accurate spatial positioning even as the player moves around their physical space.

### Target Entities

The targets that players punch are represented by `TargetEntity` objects. Each target is associated with a specific punch type (jab, cross, hook, etc.) and hand (left or right):

```swift
class TargetEntity: Entity {
    let configuration: TargetEntityConfiguration
    var shouldIgnoreCollision = false
    private let modelEntity: Entity
    
    // Noise to simulate punches to different parts of the body
    private let positionNoise = SIMD3<Float>(
        .random(in: -0.45...0.45),
        .random(in: -0.45...0.45),
        0
    )
    
    // Target initialization with collision detection
    init(configuration: TargetEntityConfiguration) async {
        self.configuration = configuration
        self.modelEntity = await Self.loadFromRealityComposerScene(configuration)
        
        super.init()
        
        self.addChild(self.modelEntity)
        
        let collisionShape = ShapeResource.generateSphere(radius: 0.3)
        let collisionComponent = CollisionComponent(shapes: [collisionShape])
        self.components.set(collisionComponent)
        self.components.set(InputTargetComponent())
        
        self.name = ImmersiveConstants.kTargetEntityName
    }
}
```

Targets move toward the player with a slightly randomized trajectory to simulate different boxing scenarios.

### Collision Detection

The game uses RealityKit's collision system to detect when a player's hand makes contact with a target:

```swift
private func handleHandTargetCollision(_ event: CollisionEvents.Began) {
    guard let targetEntity = event.entity(of: TargetEntity.self),
          !targetEntity.shouldIgnoreCollision,
          let handJointEntity = event.entity(of: HandJointEntity.self) else { return }

    self.bodyEntity.playAudio(Sounds.Punch.hit.audioResource)
    self.gameModel.handlePunch(targetEntity.configuration.punch)

    let animationDuration = 0.3
    targetEntity.playSqueezeAnimation(duration: animationDuration)
    targetEntity.shouldIgnoreCollision = true

    Task { @MainActor in
        try? await Task.sleep(nanoseconds: UInt64(animationDuration * 1_000_000_000))
        targetEntity.removeFromParent()
    }
}
```

When a collision occurs, we:
1. Play a hit sound effect
2. Update the game score
3. Animate the target (squeeze animation)
4. Remove the target after the animation

### Dodge Mechanics

In addition to targets to hit, the game includes obstacles that players must dodge:

```swift
@MainActor
func spawnDodge() async throws {
    let speed = self.gameModel.round?.level.speed ?? Level.easy.speed
    let target = await DodgeEntity(speed: speed)
    target.position = SIMD3<Float>(0,
                                   Float(Constants.saved.dodgeEntitySpawnHeight),
                                   Float(Constants.saved.dodgeEntitySpawnDistance))

    self.spaceOrigin.addChild(target)
}
```

If a dodge entity collides with the player's body, it results in a missed combo and score penalty.

### In-Game UI

The game displays crucial information to the player using a floating UI panel that shows:
- Time remaining in the current round
- Current combo multiplier
- Total score

```swift
struct InGameView: View {
    @Environment(GameModel.self) var gameModel

    var body: some View {
        VStack {
            Text("Time left: \(self.gameModel.roundState.timeLeft) s")
            Text("Combo multiplier x\(self.gameModel.roundState.comboMultiplier)")
                .bold()
            Text("Your score \(self.gameModel.roundState.score)")
                .underline()
            Button("Finish") {
                self.gameModel.finishGame()
            }
            .padding()
        }
        .font(.system(size: 30))
        .padding(20)
        .glassBackgroundEffect()
    }
}
```

This UI is attached to the spatial scene using a `BillboardComponent` that ensures it always faces the player, regardless of their position.

## Technical Challenges

Building an immersive AR experience for Apple Vision Pro presented several challenges:

### 1. Precise Hand Tracking

Accurately detecting punch movements required careful consideration of which hand joints to track. We found that tracking 16 key joints per hand provided the right balance between accuracy and performance.

### 2. Spatially-Aware Collision Detection

Ensuring that collisions felt natural and responsive required fine-tuning of collision shapes and handling logic. We use sphere-shaped collision volumes that match the visual appearance of targets while being forgiving enough for gameplay.

### 3. Performance Optimization

Maintaining a smooth frame rate is critical for immersive experiences. We had to optimize entity creation, collision detection, and rendering to ensure the game runs smoothly.

## Next Steps

In Part 2 of this series, we'll dive deeper into the gaming logic, including:
- The combo system
- Scoring mechanics
- Difficulty progression
- Round management

We'll explore how the game evaluates player performance and provides appropriate challenges based on skill level.

Stay tuned for the next article where we'll complete our exploration of building an immersive boxing game for Apple Vision Pro! 