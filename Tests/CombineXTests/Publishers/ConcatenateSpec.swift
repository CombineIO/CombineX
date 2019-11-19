import CXShim
import CXTestUtility
import Nimble
import Quick

class ConcatenateSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should concatenate two publishers
            it("should concatenate two publishers") {
                let p0 = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4])
                let p1 = Just(5)
                
                let pub = Publishers.Concatenate(prefix: p0, suffix: p1)
                let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                
                pub.subscribe(sub)
                
                let valueEvents = (1...5).map { TestSubscriberEvent<Int, Never>.value($0) }
                let expected = valueEvents + [.completion(.finished)]
                expect(sub.events) == expected
            }
            
            // MARK: 1.2 should send as many value as demand
            it("should send as many value as demand") {
                let p0 = Publishers.Sequence<[Int], Never>(sequence: Array(0..<10))
                let p1 = Publishers.Sequence<[Int], Never>(sequence: Array(10..<20))
                
                let pub = Publishers.Concatenate(prefix: p0, suffix: p1)
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { v in
                    [0, 10].contains(v) ? .max(1) : .none
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                let events = (0..<12).map { TestSubscriberEvent<Int, Never>.value($0) }
                expect(sub.events) == events
            }
            
            // MARK: 1.3 should subscribe suffix after the finish of prefix
            it("should subscribe suffix after the finish of prefix") {
                enum Event {
                    case subscribeToPrefix
                    case beforePrefixFinish
                    case afterPrefixFinish
                    case subscribeToSuffix
                }
                var events: [Event] = []
                
                let pub1 = TestPublisher<Int, Never> { s in
                    events.append(.subscribeToPrefix)
                    s.receive(subscription: Subscriptions.empty)
                    events.append(.beforePrefixFinish)
                    s.receive(completion: .finished)
                    events.append(.afterPrefixFinish)
                }
                let pub2 = TestPublisher<Int, Never> { s in
                    events.append(.subscribeToSuffix)
                    s.receive(subscription: Subscriptions.empty)
                }
                
                let pub = pub1.append(pub2)
                let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                
                pub.subscribe(sub)
                
                expect(events) == [
                    .subscribeToPrefix,
                    .beforePrefixFinish,
                    .subscribeToSuffix,
                    .afterPrefixFinish
                ]
            }
        }
    }
}
