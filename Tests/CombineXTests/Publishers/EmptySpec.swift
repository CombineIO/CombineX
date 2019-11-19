import CXShim
import CXTestUtility
import Nimble
import Quick

class EmptySpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send completion immediately
            it("should send completion immediately") {
                let empty = Empty<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                empty.subscribe(sub)
                
                expect(sub.events) == [.completion(.finished)]
            }
            
            // MARK: 1.2 should send nothing
            it("should send nothing") {
                let empty = Empty<Int, Never>(completeImmediately: false)
                let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                empty.subscribe(sub)
                expect(sub.events) == []
            }
        }
        
        // MARK: - Equal
        describe("Equal") {
            
            // MARK: 2.1 should equal if 'completeImmediately' are the same
            it("should equal if 'completeImmediately' are the same") {
                
                let e1 = Empty<Int, Never>()
                let e2 = Empty<Int, Never>()
                let e3 = Empty<Int, Never>(completeImmediately: false)
                
                expect(e1) == e2
                expect(e1) != e3
            }
        }
    }
}
