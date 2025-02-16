//
//  CalendarModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/7/24.
//

import Foundation
import Alamofire
import SwiftSoup

class CalendarModel: ObservableObject {
    @Published var islamicDay: String = ""
    @Published var islamicMonth: IslamicMonth = .none
    @Published var islamicYear: String = ""
    
    @Published var importantDates: [ImportantDate] = []
    
    init() {
        guard let islamicDate = CalendarModel.islamicDate(from: Date()) else { return }
        
        self.islamicDay = String(islamicDate.islamicDay)
        self.islamicMonth = islamicDate.islamicMonth
        self.islamicYear = String(islamicDate.islamicYear)
        
        loadImportantDates()
    }
    
    static func islamicDate(from date: Date) -> (islamicDay: Int, islamicMonth: IslamicMonth, islamicYear: Int)? {
        func intPart(_ value: Int) -> Int {
            return Int(floor(Double(value)))
        }
        
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        
        guard let day = components.day, let month = components.month, let year = components.year else {
            return nil
        }
        
        let julianDay: Int
        if year > 1582 || (year == 1582 && month > 10) || (year == 1582 && month == 10 && day > 14) {
            julianDay = intPart((1461 * (year + 4800 + intPart((month - 14) / 12))) / 4) + intPart((367 * (month - 2 - 12 * intPart((month - 14) / 12))) / 12) - intPart((3 * (intPart((year + 4900 + intPart((month - 14) / 12)) / 100))) / 4) + day - 32075
        } else {
            julianDay = 367 * year - intPart((7 * (year + 5001 + intPart((month - 9) / 7))) / 4) + intPart((275 * month) / 9) + day + 1729777
        }
        
        var daysSinceEpoch = julianDay - 1948440 + 10632
        let cycles = intPart((daysSinceEpoch - 1) / 10631)
        daysSinceEpoch = daysSinceEpoch - 10631 * cycles + 354
        let adjustedYear = (intPart((10985 - daysSinceEpoch) / 5316)) * (intPart((50 * daysSinceEpoch) / 17719)) + (intPart(daysSinceEpoch / 5670)) * (intPart((43 * daysSinceEpoch) / 15238))
        daysSinceEpoch = daysSinceEpoch - (intPart((30 - adjustedYear) / 15)) * (intPart((17719 * adjustedYear) / 50)) - (intPart(adjustedYear / 16)) * (intPart((15238 * adjustedYear) / 43)) + 29
        let islamicMonth = intPart((24 * daysSinceEpoch) / 709)
        let islamicDay = daysSinceEpoch - intPart((709 * islamicMonth) / 24)
        let islamicYear = 30 * cycles + adjustedYear - 30
        
        guard let islamicMonth = IslamicMonth(monthNumber: islamicMonth) else { return nil }
        
        return (islamicDay, islamicMonth, islamicYear)
    }
    
    private func loadImportantDates() {
        guard let importantDates = JSONDecoder.decode(from: "ImportantDates", to: [ImportantDate].self) else { return }
        
        self.importantDates = importantDates
    }
}
