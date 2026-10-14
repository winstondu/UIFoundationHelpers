//
//  Date+.swift
//  Winston
//
//

import Foundation

public extension Date {
    func smartDateInfo(relativeTo reference: Date = .init()) -> String {
        let interval = abs(reference.timeIntervalSince(self))
        let minute: Double = 60
        let hour: Double = 60 * minute
        let day: Double = 24 * hour

        switch interval {
        case ..<5:
            return "Just now"
        case ..<minute: // Seconds
            return "\(Int(interval.rounded()))s"
        case ..<hour: // Minutes
            return "\(Int((interval / minute).rounded()))m"
        case ..<day: // Hours
            return "\(Int((interval / hour).rounded()))h"
        case ..<(5 * day): // Days (ceiled so 1.3 d → 2d)
            let days = Int(ceil(interval / day))
            return "\(days)d"
        default: // Calendar date (M/d)
            let f = DateFormatter()
            f.dateFormat = "M/d"
            return f.string(from: self)
        }
    }

    var timeAgoString: String {
        let now = Date()
        let seconds = Int(now.timeIntervalSince(self))

        if seconds < 60 { return "Just now" }

        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes) min" }

        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }

        let days = hours / 24
        if days == 1 { return "Yesterday" }
        if days < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        }

        return "\(days)d ago"
    }
}

extension Int {
    var second: TimeInterval { TimeInterval(self) }
    var seconds: TimeInterval { TimeInterval(self) }

    var minute: TimeInterval { TimeInterval(self) * 60 }
    var minutes: TimeInterval { minute }

    var hour: TimeInterval { minute * 60 }
    var hours: TimeInterval { hour }
}

extension Double {
    var second: TimeInterval { self }
    var seconds: TimeInterval { self }
    var minute: TimeInterval { self * 60 }
    var minutes: TimeInterval { minute }
    var hour: TimeInterval { minute * 60 }
    var hours: TimeInterval { hour }
}
