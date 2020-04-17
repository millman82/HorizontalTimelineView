import Foundation

public class DowntimeInterval: NSObject {
    public let startTime: Date
    public let endTime: Date
    
    public init(from start: Date, to end: Date) {
        startTime = start
        endTime = end
    }
}
