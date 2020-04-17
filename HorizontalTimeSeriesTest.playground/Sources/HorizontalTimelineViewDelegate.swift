import Foundation

@objc public protocol HorizontalTimelineViewDelegate {
    @objc optional func downtimeTapped(downtimeInterval: DowntimeInterval)
}
