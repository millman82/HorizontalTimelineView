import UIKit

public class HorizontalTimelineView: UIView {
    
    private let uptimeColor = UIColor.green
    private let downtimeColor = UIColor.red
    private var downtimeRegionIndexes = [(start: CGFloat, end: CGFloat)]()
    
    public var startTime: Date!
    public var endTime: Date!
    public var downTimeIntervals: [DowntimeInterval]!
    public weak var delegate: HorizontalTimelineViewDelegate?
    
    public override func draw(_ rect: CGRect) {
        
        downtimeRegionIndexes.removeAll()
        
        let lineY = rect.height / 2
        
        if downTimeIntervals.count == 0 {
            if let context = UIGraphicsGetCurrentContext() {
                context.setLineWidth(rect.height)
                context.setStrokeColor(uptimeColor.cgColor)
                context.move(to: CGPoint(x: 0, y: lineY))
                context.addLine(to: CGPoint(x: rect.width, y: lineY))
                context.strokePath()
            }
        } else {
            let intervalRange = CGFloat(DateInterval(start: startTime, end: endTime).duration)
            
            let intervals = computeIntervals()
            
            var previousPathEndX = CGFloat(0.0)
            for interval in intervals {
                
                let distance = rect.width * CGFloat(interval.interval.duration) / intervalRange
                let start = previousPathEndX
                let end = previousPathEndX + distance
                
                if interval.availabilityStatus == .down {
                    downtimeRegionIndexes.append((start: start, end: end))
                }
                
                if let context = UIGraphicsGetCurrentContext() {
                    context.setLineWidth(rect.height)
                    
                    switch interval.availabilityStatus {
                    case .down:
                        context.setStrokeColor(downtimeColor.cgColor)
                    case .up:
                        context.setStrokeColor(uptimeColor.cgColor)
                    }
                    
                    context.move(to: CGPoint(x: start, y: lineY))
                    context.addLine(to: CGPoint(x: end, y: lineY))
                    context.strokePath()
                }
                
                previousPathEndX = end
            }
        }
    }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Tapped")
        
        var tappedDowntimeIndex = -1
        if downtimeRegionIndexes.count > 0 {
            for (i, region) in downtimeRegionIndexes.enumerated() {
                let location = gestureRecognizer.location(in: self)
                
                if location.x > region.start && location.x < region.end {
                    tappedDowntimeIndex = i
                    break
                }
            }
            
            print("\(tappedDowntimeIndex)")
            if tappedDowntimeIndex > -1 {
                let downtimeInterval = downTimeIntervals[tappedDowntimeIndex]
                
                delegate?.downtimeTapped?(downtimeInterval: downtimeInterval)
            }
        }
    }
    
    private func computeIntervals() -> [StatusInterval] {
        var intervals = [StatusInterval]()
        let startingState: AvailabilityStatus = downTimeIntervals.first!.startTime <= startTime ? .down : .up
        if startingState == .up {
            let uptimeInterval = DateInterval(start: startTime, end: downTimeIntervals[0].startTime)
            intervals.append(StatusInterval(availabilityStatus: .up, interval: uptimeInterval))
            let downtimeInterval = DateInterval(start: downTimeIntervals[0].startTime, end: downTimeIntervals[0].endTime)
            intervals.append(StatusInterval(availabilityStatus: .down, interval: downtimeInterval))
        } else {
            let downtimeInterval = DateInterval(start: startTime, end: downTimeIntervals[0].endTime)
            intervals.append(StatusInterval(availabilityStatus: .down, interval: downtimeInterval))
        }
        
        if (downTimeIntervals.count > 1) {
            for i in 1...downTimeIntervals.count - 1 {
                let last = intervals.last!
                let uptimeInterval = DateInterval(start: last.interval.end, end: downTimeIntervals[i].startTime)
                intervals.append(StatusInterval(availabilityStatus: .up, interval: uptimeInterval))
                
                let downtimeInterval = DateInterval(start: downTimeIntervals[i].startTime, end: downTimeIntervals[i].endTime)
                intervals.append(StatusInterval(availabilityStatus: .down, interval: downtimeInterval))
            }
        }
        
        if intervals.last!.interval.end < endTime {
            let uptimeInterval = DateInterval(start: intervals.last!.interval.end, end: endTime)
            intervals.append(StatusInterval(availabilityStatus: .up, interval: uptimeInterval))
        }
        
        return intervals
    }
    
    private func registerTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HorizontalTimelineView.tap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        registerTapGestureRecognizer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .white
        
        registerTapGestureRecognizer()
    }
}
