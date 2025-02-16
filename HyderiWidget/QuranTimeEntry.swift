//
//  QuranTimeEntry.swift
//  Hyderi
//
//  Created by Ali Earp on 12/25/24.
//

import WidgetKit
import Foundation

struct QuranTimeEntry: TimelineEntry {
    let date: Date
    
    let quranTimes: [QuranTime]
    
    let islamicDay: Int
    let islamicMonth: IslamicMonth
    let islamicYear: Int
    
    init(date: Date, quranTimes: [QuranTime], islamicDay: Int, islamicMonth: IslamicMonth, islamicYear: Int) {
        self.date = date
        self.quranTimes = quranTimes
        self.islamicDay = islamicDay
        self.islamicMonth = islamicMonth
        self.islamicYear = islamicYear
    }
    
    init(date: Date, _ quranTimes: [QuranTime], _ islamicDay: Int, _ islamicMonth: IslamicMonth, _ islamicYear: Int) {
        self.date = date
        self.quranTimes = quranTimes
        self.islamicDay = islamicDay
        self.islamicMonth = islamicMonth
        self.islamicYear = islamicYear
    }
}
