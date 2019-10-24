import Foundation

enum TimeIntervalEventType: String {
    case userPrecievedListResponseTime = "userPrecievedListResponseTime"
    case networkListResponseTime = "networkListResponseTime"
    case rawNetworkListResponseTime = "rawNetworkListResponseTime"
}

class TimeIntervalEventTracker {
  static let printThreshold = 0.2

  var events: [TimeIntervalEventType : Date] = [:]

  static let shared = TimeIntervalEventTracker()

  class func trackStart(event: TimeIntervalEventType) {
    shared.events[event] = Date()
  }

  class func trackEnd(event: TimeIntervalEventType) {

    if let startDate = shared.events[event] {
      shared.events.removeValue(forKey: event)
      let elapsed = Date().timeIntervalSince(startDate)
      if elapsed > printThreshold {
        print("\n\n> time \(event.rawValue): \(elapsed) sec")
      }
    }
  }
}
