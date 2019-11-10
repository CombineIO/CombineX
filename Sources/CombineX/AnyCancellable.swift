/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
/// An AnyCancellable instance automatically calls `cancel()` when deinitialized.
final public class AnyCancellable: Cancellable, Hashable {
    
    private var cancelBody: (() -> Void)?

    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancel: @escaping () -> Void) {
        self.cancelBody = cancel
    }
    
    public init<C>(_ canceller: C) where C: Cancellable {
        self.cancelBody = canceller.cancel
    }
    
    final public func cancel() {
        self.cancelBody?()
        self.cancelBody = nil
    }
    
    deinit {
        self.cancelBody?()
    }
    
    final public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

extension AnyCancellable {
    
    /// Stores this AnyCancellable in the specified collection.
    /// Parameters:
    ///    - collection: The collection to store this AnyCancellable.
    final public func store<C>(in collection: inout C) where C : RangeReplaceableCollection, C.Element == AnyCancellable {
        collection.append(self)
    }
    
    /// Stores this AnyCancellable in the specified set.
    /// Parameters:
    ///    - collection: The set to store this AnyCancellable.
    final public func store(in set: inout Set<AnyCancellable>) {
        set.insert(self)
    }

}

