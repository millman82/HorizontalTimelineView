//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    let secondsInDay = 86400.0
    
    override func loadView() {
        let timelineView = HorizontalTimelineView()
        let currentDate = Date()
        let startDate = currentDate - TimeInterval(exactly: secondsInDay * 14)!
                
        let downInterval1Start = currentDate - TimeInterval(exactly: secondsInDay * 12)!
        let downInterval1End = currentDate - TimeInterval(exactly: secondsInDay * 11.2)!
        
        let downInterval2Start = currentDate - TimeInterval(exactly: secondsInDay * 8)!
        let downInterval2End = currentDate - TimeInterval(exactly: secondsInDay * 6.7)!
        
        timelineView.startTime = startDate
        timelineView.endTime = currentDate
        timelineView.delegate = self
        var downtimeIntervals = [DowntimeInterval]()
        downtimeIntervals.append(DowntimeInterval(from: downInterval1Start, to: downInterval1End))
        downtimeIntervals.append(DowntimeInterval(from: downInterval2Start, to: downInterval2End))
        
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

extension MyViewController: HorizontalTimelineViewDelegate {
    func downtimeTapped(downtimeInterval: DowntimeInterval) {
        
        let alert = UIAlertController(title: "Downtime", message: "start: \(downtimeInterval.startTime) end: \(downtimeInterval.endTime)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.modalPresentationStyle = .popover
        present(alert, animated: true, completion: nil)
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
