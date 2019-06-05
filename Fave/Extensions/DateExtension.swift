import Foundation

extension Date {
    func condensedTimeSinceString() -> String {

        let calendar = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: Date(), to: self)

        if let year = calendar.year, abs(year) > 0 {
            return "\(abs(year))y"
        }

        if let month = calendar.month, abs(month) > 0 {
            return "\(abs(month))mo"
        }

        if let week = calendar.weekOfYear, abs(week) > 0 {
            return "\(abs(week))mo"
        }

        if let day = calendar.day, abs(day) > 0 {
            return "\(abs(day))d"
        }

        if let hour = calendar.hour, abs(hour) > 0 {
            return "\(abs(hour))h"
        }

        if let minute = calendar.minute, abs(minute) > 0 {
            return "\(abs(minute))m"
        }

        if let second = calendar.second, abs(second) > 0 {
            return "\(abs(second))s"
        }

        return ""
    }
}
