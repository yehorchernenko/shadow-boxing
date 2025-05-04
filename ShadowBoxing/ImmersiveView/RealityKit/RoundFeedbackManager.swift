import Foundation
import RealityKit
import SwiftUI

/// A class that manages immersive 3D text feedback in the scene
class RoundFeedbackManager {
    // Parent entity to attach feedback text to
    private let parent: Entity
    
    // Current active feedback entity
    private var currentFeedbackEntity: Entity?
    
    // Configuration options
    private let defaultPosition = SIMD3<Float>(0, 1.5, -1)
    private let displayDuration: TimeInterval = 1.5
    
    init(parent: Entity) {
        self.parent = parent
    }
    
    /// Shows immersive 3D text feedback in the scene
    func showText(_ message: String, color: Color, position: SIMD3<Float>? = nil) {
        // Remove any existing feedback entity
        self.currentFeedbackEntity?.removeFromParent()
        
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
        var material = SimpleMaterial()
        
        // Handle common colors
        switch color {
        case .yellow:
            material = SimpleMaterial(color: .yellow, isMetallic: false)
        case .green:
            material = SimpleMaterial(color: .green, isMetallic: false)
        default:
            material = SimpleMaterial(color: .white, isMetallic: false)
        }
        
        // Create model entity with the text mesh and material
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        
        // Position the text in front of the user
        textEntity.position = position ?? defaultPosition
        
        // Add billboard component to make text always face the user
        textEntity.components.set(BillboardComponent())
        
        // Store reference to the feedback entity
        self.currentFeedbackEntity = textEntity
        
        // Add to the scene
        parent.addChild(textEntity)
        
        // Hide feedback after delay
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(displayDuration * 1_000_000_000))
            textEntity.removeFromParent()
            if self.currentFeedbackEntity == textEntity {
                self.currentFeedbackEntity = nil
            }
        }
    }
} 