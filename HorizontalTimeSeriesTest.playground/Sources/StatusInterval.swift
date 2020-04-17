import Foundation

public enum AvailabilityStatus {
    case up
    case down
}

public struct StatusInterval {
    public let availabilityStatus: AvailabilityStatus
    public let interval: DateInterval
}
