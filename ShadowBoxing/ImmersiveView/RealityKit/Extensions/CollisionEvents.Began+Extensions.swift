import RealityKit

extension CollisionEvents.Began {
    func entity<T: Entity>(of type: T.Type) -> T? {
        return [self.entityA, self.entityB].compactMap({ $0 as? T }).first
    }
}
