import CXShim
import CXTestUtility
import Nimble
import Quick

class OutputSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            xit("should not receive values even if no subscription is received") {
                let pub = TestPublisher<Int, Error> { s in
                    _ = s.receive(0)
                    _ = s.receive(1)
                    _ = s.receive(2)
                    _ = s.receive(3)
                    _ = s.receive(4)
                }
                
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                pub.output(in: 0..<2).subscribe(sub)
                
                let got = sub.events.mapError { $0 as! TestError }
                
                // FIXME: Even if the upstream doesn't send subscription, the downstream still can receive values. 🤔.
                expect(got) == [.value(0), .value(1)]
            }
            
            // MARK: 1.1 should only send values specified by the range
            it("should only send values in the specified range") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.output(in: 10..<20)
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { _ in
                    return .none
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                let valueEvents = (10..<20).map {
                    TestSubscriberEvent<Int, Never>.value($0)
                }
                let expected = valueEvents + [.completion(.finished)]
                expect(sub.events) == expected
            }
            
            // MARK: 1.2 should send values as demand
            it("should send values as demand") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.output(in: 10..<20)
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(5))
                }, receiveValue: { v in
                    [10, 15].contains(v) ? .max(1) : .none
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                let expected = (10..<17).map {
                    TestSubscriberEvent<Int, Never>.value($0)
                }
                expect(sub.events) == expected
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.3 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.output(in: 0..<10)
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.output(in: 0..<10)
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
