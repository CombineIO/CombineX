import CXShim
import CXTestUtility
import Nimble
import Quick

class TryScanSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should scan values from upstream
            it("should scan values from upstream") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                subject.tryScan(0) {
                    $0 + $1
                }.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                subject.send(completion: .finished)
                
                let got = sub.events.mapError { $0 as! TestError }
                
                var initial = 0
                let valueEvents = (0..<100).map { n -> TestSubscriberEvent<Int, TestError> in
                    initial += n
                    return TestSubscriberEvent<Int, TestError>.value(initial)
                }
                let expected = valueEvents + [.completion(.finished)]

                expect(got) == expected
            }
            
            // MARK: 1.2 should fail if closure throws an error
            it("should fail if closure throws an error") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                subject.tryScan(0) { _, _ in
                    throw TestError.e0
                }.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                let got = sub.events.mapError { $0 as! TestError }
                expect(got) == [.completion(.failure(.e0))]
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.3 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryScan(0) { $0 + $1 }
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.tryScan(0) { $0 + $1 }
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)

                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
