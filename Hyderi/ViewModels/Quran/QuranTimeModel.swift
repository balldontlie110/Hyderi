//
//  QuranTimeModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/24/24.
//

import SwiftUI
import WidgetKit

class QuranTimeModel: ObservableObject {
    @AppStorage("streak") private static var streak: Int = 0
    
    @discardableResult
    static func updateStreak(quranTimes: [QuranTime], refreshWidgets: Bool = true) -> Int {
        guard var last = quranTimes.last?.date, let gap = Calendar.current.dateComponents([.day], from: last, to: Date()).day, gap <= 1 else {
            streak = 0
            
            return 0
        }
        
        var count = 0
        
        for index in quranTimes.indices.reversed() {
            if Calendar.current.isDate(quranTimes[index].date, inSameDayAs: last) && quranTimes[index].time >= .minimumStreak {
                count += 1
                
                guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: last) else { break }
                
                last = previousDate
            } else if Calendar.current.isDateInToday(quranTimes[index].date) {
                guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: last) else { break }
                
                last = previousDate
            } else {
                break
            }
        }
        
        streak = count
        
        if refreshWidgets {
            WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuranTimeWidget")
        }
        
        return count
    }
}

extension Int64 {
    static let minimumStreak: Int64 = 300
}
