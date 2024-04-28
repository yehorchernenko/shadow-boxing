import Foundation
import SwiftUI

/// A property wrapper that reads and writes to `UserDefaults` using `Codable`.
/// This property conforms to `DynamicProperty` so that the view updates when the value changes.
@propertyWrapper
struct UserDefaultCodable<Value: Codable>: DynamicProperty {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    @State private var value: Value? = nil

    var wrappedValue: Value {
        get {
            self.value ?? Self.getSavedValue(container: container, key: key) ?? self.defaultValue
        }
        nonmutating set {
            self.value = newValue
            if let data = try? JSONEncoder().encode(newValue) {
                self.container.set(data, forKey: key)
            }
        }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                self.wrappedValue = newValue
            }
        )
    }

    private static func getSavedValue(container: UserDefaults, key: String) -> Value? {
        guard let data = container.object(forKey: key) as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(Value.self, from: data)
    }
}
