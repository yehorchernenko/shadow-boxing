import Foundation
import RealityKit
import ARKit

/// Result of punch validation
enum PunchValidationResult {
    case valid
    case wrongHand
    case wrongMovement
}

/// A class that validates if punches were executed correctly
class PunchValidator {
    
    /// Validates if a punch was executed correctly
    /// - Parameters:
    ///   - punch: The punch that should be executed
    ///   - handChirality: The hand that was used (left or right)
    ///   - movements: The movements detected
    /// - Returns: The validation result
    static func validate(
        punch: Punch,
        handChirality: AnchoringComponent.Target.Chirality,
        movements: Set<MovementDirection>
    ) -> PunchValidationResult {
        
        // First check if the correct hand was used
        let isCorrectHand = (punch.hand == .left && handChirality == .left) || 
                           (punch.hand == .right && handChirality == .right)
        
        if !isCorrectHand {
            return .wrongHand
        }
        
        // Then check if the movement pattern matches the punch type
        let isCorrectMovement = isMovementValid(for: punch.kind, movements: movements)
        
        if !isCorrectMovement {
            return .wrongMovement
        }
        
        return .valid
    }
    
    /// Determines if the movement pattern matches the expected punch type
    /// - Parameters:
    ///   - punchKind: The kind of punch
    ///   - movements: The detected movements
    /// - Returns: Whether the movement is valid for the punch type
    static func isMovementValid(for punchKind: Punch.Kind, movements: Set<MovementDirection>) -> Bool {
        switch punchKind {
        case .jab, .cross:
            // Jab is primarily a forward movement
            // Cross is also primarily a forward movement, just with the rear hand
            return movements.contains(.forward)
            
        case .hook:
            // Left or right movement is the primary component of a hook
            return movements.contains(.left) || movements.contains(.right)
            
        case .uppercut:
            // Uppercut is primarily an upward movement
            return movements.contains(.up)
        }
    }
} 
