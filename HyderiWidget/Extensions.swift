//
//  Extensions.swift
//  Hyderi
//
//  Created by Ali Earp on 12/14/24.
//

import SwiftUI

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func startOfWeek() -> Date? {
        Calendar.current.dateInterval(of: .weekOfYear, for: self)?.start
    }
    
    func time() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
    
    func timeSinceNow(unitsStyle: RelativeDateTimeFormatter.UnitsStyle) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = unitsStyle
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func shortTimeSinceNow() -> String? {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        
        return formatter.string(from: Date(), to: self)
    }
    
    func isBefore(date: Date) -> Bool {
        let selfHour = self.component(.hour)
        let selfMinute = self.component(.minute)
        
        let dateHour = date.component(.hour)
        let dateMinute = date.component(.minute)
        
        if selfHour < dateHour {
            return true
        } else if selfHour > dateHour {
            return false
        } else {
            return selfMinute < dateMinute
        }
    }
    
    func isAfter(date: Date) -> Bool {
        let selfHour = self.component(.hour)
        let selfMinute = self.component(.minute)
        
        let dateHour = date.component(.hour)
        let dateMinute = date.component(.minute)
        
        if selfHour < dateHour {
            return false
        } else if selfHour > dateHour {
            return true
        } else {
            return selfMinute > dateMinute
        }
    }
    
    func component(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
}

extension String {
    func date(using format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.defaultDate = Date()
        formatter.dateFormat = "HH:mm"
        
        return formatter.date(from: self)
    }
}

extension JSONDecoder {
    static func decode<T: Decodable>(from file: String, to type: T.Type) -> T? {
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else { return nil }
        
        do {
            let data = try Data(contentsOf: URL(filePath: path))
            let result = try JSONDecoder().decode(T.self, from: data)
            
            return result
        } catch {
            print(error)
            
            return nil
        }
    }
}

extension Prayer {
    var nextPrayer: String {
        switch self {
        case .fajr: return "Fajr starts"
        case .sunrise: return "Fajr ends"
        case .zuhr: return "Zuhr starts"
        case .sunset: return "Zuhr ends"
        case .maghrib: return "Maghrib starts"
        case .midnight: return "Maghrib ends"
        }
    }
}

extension EnvironmentValues {
    @Entry var quranTimes: [QuranTime] = []
}
