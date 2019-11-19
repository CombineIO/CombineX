import CXShim
import CXTestUtility
import Dispatch
import Nimble
import Quick

typealias ResultPublisher<Success, Failure: Error> = Result<Success, Failure>.CX.Publisher

class ResultSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send a value then send finished
            it("should send value then send finished") {
                let pub = ResultPublisher<Int, TestError>(1)
                
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                expect(sub.events) == [.value(1), .completion(.finished)]
            }
            
            // MARK: 1.2 should send failure even no demand
            it("should send failure") {
                let pub = ResultPublisher<Int, TestError>(.e0)
                
                let sub = makeTestSubscriber(Int.self, TestError.self, .max(0))
                pub.subscribe(sub)
                
                expect(sub.events) == [.completion(.failure(.e0))]
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.3 should throw assertion when none demand is requested
            it("should throw assertion when less than one demand is requested") {
                let pub = ResultPublisher<Int, TestError>(1)
                let sub = makeTestSubscriber(Int.self, TestError.self, .max(0))
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when none demand is requested if is nil
            it("should not throw assertion when none demand is requested if is failure") {
                let pub = ResultPublisher<Int, TestError>(.e0)
                let sub = makeTestSubscriber(Int.self, TestError.self, .max(0))
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
