//
//  Event.swift
//  Hyderi
//
//  Created by Ali Earp on 12/30/24.
//

import Foundation

enum EventTime: Int, CaseIterable {
    case none = 1
    case now = 2
    case in5Minutes = 3
    case in10Minutes = 4
    case in15Minutes = 5
    case in30Minutes = 6
    case in1Hour = 7
    case in2Hours = 8
    case tomorrow = 9
    
    var menuString: String {
        switch self {
        case .none: return "Remove notification"
        case .now: return "At time of event"
        case .in5Minutes: return "5 minutes before"
        case .in10Minutes: return "10 minutes before"
        case .in15Minutes: return "15 minutes before"
        case .in30Minutes: return "30 minutes before"
        case .in1Hour: return "1 hour before"
        case .in2Hours: return "2 hours before"
        case .tomorrow: return "Day before"
        }
    }
    
    var notificationString: String {
        switch self {
        case .none: return ""
        case .now: return "now"
        case .in5Minutes: return "in 5 minutes"
        case .in10Minutes: return "in 10 minutes"
        case .in15Minutes: return "in 15 minutes"
        case .in30Minutes: return "in 30 minutes"
        case .in1Hour: return "in 1 hour"
        case .in2Hours: return "in 2 hours"
        case .tomorrow: return "tomorrow"
        }
    }
    
    func addingTime(to date: Date) -> Date? {
        switch self {
        case .none:
            return nil
        case .now:
            return date
        case .in5Minutes:
            return Calendar.current.date(byAdding: .minute, value: -5, to: date)
        case .in10Minutes:
            return Calendar.current.date(byAdding: .minute, value: -10, to: date)
        case .in15Minutes:
            return Calendar.current.date(byAdding: .minute, value: -15, to: date)
        case .in30Minutes:
            return Calendar.current.date(byAdding: .minute, value: -30, to: date)
        case .in1Hour:
            return Calendar.current.date(byAdding: .hour, value: -1, to: date)
        case .in2Hours:
            return Calendar.current.date(byAdding: .hour, value: -2, to: date)
        case .tomorrow:
            return Calendar.current.date(byAdding: .day, value: -1, to: date)
        }
    }
}

extension EventTime {
    static func allCases(_ notifyingEventTime: EventTime) -> [EventTime] {
        if notifyingEventTime == .none {
            return EventTime.allCases.filter({ $0 != .none })
        } else {
            return EventTime.allCases
        }
    }
}
