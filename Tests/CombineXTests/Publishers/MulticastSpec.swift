import CXShim
import CXTestUtility
import Nimble
import Quick

class MulticastSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        describe("Relay") {
            
            // MARK: 1.1 should multicase after connect
            it("should multicase after connect") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.multicast(subject: PassthroughSubject<Int, TestError>())
                
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                10.times {
                    subject.send($0)
                }
                expect(sub.events) == []
                
                let cancel = pub.connect()
                
                10.times {
                    subject.send($0)
                }
                expect(sub.events) == (0..<10).map { .value($0) }
                
                cancel.cancel()
                
                10.times {
                    subject.send($0)
                }
                
                expect(sub.events) == (0..<10).map { .value($0) }
            }
        }
    }
}
