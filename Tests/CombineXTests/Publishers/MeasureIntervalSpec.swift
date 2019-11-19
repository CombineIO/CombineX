import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class MeasureIntervalSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
    
        // MARK: Measure Interval
        describe("Measure Interval") {
            
            // MARK: 1.1 should measure interval as expected
            it("should measure interval as expected") {
                let subject = PassthroughSubject<Int, Never>()
                
                let pub = subject.measureInterval(using: TestDispatchQueueScheduler.main)
                var t = Date()
                var dts: [TimeInterval] = []
                let sub = TestSubscriber<TestDispatchQueueScheduler.SchedulerTimeType.Stride, Never>(receiveSubscription: { s in
                    s.request(.unlimited)
                    t = Date()
                }, receiveValue: { _ in
                    dts.append(-t.timeIntervalSinceNow)
                    t = Date()
                    return .none
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                Thread.sleep(forTimeInterval: 0.2)
                subject.send(1)
                
                Thread.sleep(forTimeInterval: 0.1)
                subject.send(1)
                
                subject.send(completion: .finished)
                
                expect(sub.events).to(haveCount(dts.count + 1))
                expect(sub.events.last) == .completion(.finished)
                for (event, dt) in zip(sub.events.dropLast(), dts) {
                    expect(event.value?.seconds).to(beCloseTo(dt, within: 0.1))
                }
            }
        }
    }
}
