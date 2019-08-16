//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

struct DowntimeInterval {
    let startTime: Date
    let endTime: Date
}

enum AvailabilityStatus {
    case up
    case down
}

struct StatusInterval {
    let availabilityStatus: AvailabilityStatus
    let interval: DateInterval
}

class HorizontalTimelineView: UIView {
    
    private let uptimeColor = UIColor.green
    private let downtimeColor = UIColor.red
    
    var startTime: Date!
    var endTime: Date!
    var downTimeIntervals: [DowntimeInterval]!
    
    override func draw(_ rect: CGRect) {
        
        let lineY = rect.height / 2
        
        if downTimeIntervals.count == 0 {
            uptimeColor.setStroke()
            let path = UIBezierPath()
            path.lineWidth = 10.0
            path.move(to: CGPoint(x: 0, y: lineY))
            path.addLine(to: CGPoint(x: rect.width, y: lineY))
            path.stroke()
        } else {
            let intervalRange = CGFloat(DateInterval(start: startTime, end: endTime).duration)
            
            let intervals = computeIntervals()
            
            var previousPathEndX = CGFloat(0.0)
            for interval in intervals {
                switch interval.availabilityStatus {
                case .down:
                    downtimeColor.setStroke()
                case .up:
                    uptimeColor.setStroke()
                }
                
                let distance = rect.width * CGFloat(interval.interval.duration) / intervalRange
                let path = UIBezierPath()
                path.lineWidth = rect.height
                path.move(to: CGPoint(x: previousPathEndX, y: lineY))
                
                previousPathEndX += distance
                path.addLine(to: CGPoint(x: previousPathEndX + distance, y: lineY))
                path.stroke()
            }
        }
    }
    
    func computeIntervals() -> [StatusInterval] {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .white
    }
}

class MyViewController : UIViewController {
    override func loadView() {
        let timelineView = HorizontalTimelineView()
        timelineView.startTime = ISO8601DateFormatter().date(from: "2019-08-08T00:00:00Z")
        timelineView.endTime = Date()
        var downtimeIntervals = [DowntimeInterval]()
        downtimeIntervals.append(DowntimeInterval(startTime: ISO8601DateFormatter().date(from: "2019-08-12T07:17:35Z")!, endTime: ISO8601DateFormatter().date(from: "2019-08-12T12:18:33Z")!))
        downtimeIntervals.append(DowntimeInterval(startTime: ISO8601DateFormatter().date(from: "2019-08-15T07:17:35Z")!, endTime: Date()))
        timelineView.downTimeIntervals = downtimeIntervals
        timelineView.frame = CGRect(x: 150, y: 220, width: 200, height: 10)
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Horizontal Timeline"
        label.textColor = .black
        
        
        view.addSubview(label)
        view.addSubview(timelineView)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
