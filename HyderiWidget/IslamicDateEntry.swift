//
//  IslamicDateEntry.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import WidgetKit
import Foundation

struct IslamicDateEntry: TimelineEntry {
    let date: Date
    
    let islamicDay: Int
    let islamicMonth: IslamicMonth
    
    init(date: Date, islamicDay: Int, islamicMonth: IslamicMonth) {
        self.date = date
        self.islamicDay = islamicDay
        self.islamicMonth = islamicMonth
    }
    
    init(date: Date, _ islamicDay: Int, _ islamicMonth: IslamicMonth) {
        self.date = date
        self.islamicDay = islamicDay
        self.islamicMonth = islamicMonth
    }
}
