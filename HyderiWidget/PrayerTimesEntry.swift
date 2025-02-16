//
//  PrayerTimesEntry.swift
//  Hyderi
//
//  Created by Ali Earp on 12/14/24.
//

import WidgetKit
import Foundation

struct PrayerTimesEntry: TimelineEntry {
    let date: Date
    
    let prayerTimes: [Prayer : Date]
    
    let islamicDay: Int
    let islamicMonth: IslamicMonth
    let islamicYear: Int
    
    init(date: Date, prayerTimes: [Prayer : Date], islamicDay: Int, islamicMonth: IslamicMonth, islamicYear: Int) {
        self.date = date
        self.prayerTimes = prayerTimes
        self.islamicDay = islamicDay
        self.islamicMonth = islamicMonth
        self.islamicYear = islamicYear
    }
    
    init(date: Date, _ prayerTimes: [Prayer : Date], _ islamicDay: Int, _ islamicMonth: IslamicMonth, _ islamicYear: Int) {
        self.date = date
        self.prayerTimes = prayerTimes
        self.islamicDay = islamicDay
        self.islamicMonth = islamicMonth
        self.islamicYear = islamicYear
    }
}

