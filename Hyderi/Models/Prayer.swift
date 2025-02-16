//
//  Prayer.swift
//  Hyderi
//
//  Created by Ali Earp on 12/8/24.
//

import Foundation

enum Prayer: String, CaseIterable, Encodable, Comparable {
    case fajr = "Dawn"
    case sunrise = "Sunrise"
    case zuhr = "Noon"
    case sunset = "Sunset"
    case maghrib = "Maghrib"
    case midnight = "Midnight"
    
    init?(name: String) {
        guard let prayer = Prayer.allCases.first(where: { $0.rawValue == name }) else { return nil }
        
        self = prayer
    }
    
    var formatted: String {
        switch self {
        case .fajr: return "Fajr"
        case .sunrise: return "Sunrise"
        case .zuhr: return "Zuhr"
        case .sunset: return "Sunset"
        case .maghrib: return "Maghrib"
        case .midnight: return "Midnight"
        }
    }
    
    var emoji: String {
        switch self {
        case .fajr: return "🕌"
        case .sunrise: return "☀️"
        case .zuhr: return "🕌"
        case .sunset: return "🌙"
        case .maghrib: return "🕌"
        case .midnight: return "🌑"
        }
    }
    
    var isPrayer: Bool {
        switch self {
        case .fajr: return true
        case .sunrise: return false
        case .zuhr: return true
        case .sunset: return false
        case .maghrib: return true
        case .midnight: return false
        }
    }
    
    var isWidget: Bool {
        return widgetCases.contains(self)
    }
    
    private var widgetCases: [Prayer] {
        return [.fajr, .sunrise, .zuhr, .sunset, .maghrib]
    }
    
    static func < (lhs: Prayer, rhs: Prayer) -> Bool {
        return lhs.number < rhs.number
    }
    
    var number: Int {
        switch self {
        case .fajr: return 1
        case .sunrise: return 2
        case .zuhr: return 3
        case .sunset: return 4
        case .maghrib: return 5
        case .midnight: return 6
        }
    }
}
