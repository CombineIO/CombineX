import CXShim
import CXTestUtility
import CXUtility
import Dispatch
import Nimble
import Quick

class CombineIdentifierSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Unique
        describe("Unique") {
            
            // MARK: 1.1 should be unique to each other
            it("should be unique to each other") {
                let set = Atom<Set<CombineIdentifier>>(val: [])
                let g = DispatchGroup()
                for _ in 0..<100 {
                    let id = CombineIdentifier()
                    DispatchQueue.global().async(group: g) {
                        _ = set.withLockMutating { $0.insert(id) }
                    }
                }
                g.wait()
                
                expect(set.get().count) == 100
            }
            
            // MARK: 1.2 should use object's address as id
            it("should use object's address as id") {
                let obj = TestObject()
                
                let id1 = CombineIdentifier(obj)
                let id2 = CombineIdentifier(obj)
                
                expect(id1) == id2
            }
        }
    }
}
