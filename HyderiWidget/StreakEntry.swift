//
//  StreakEntry.swift
//  Hyderi
//
//  Created by Ali Earp on 12/24/24.
//

import WidgetKit
import Foundation

struct StreakEntry: TimelineEntry {
    let date: Date
    
    let streak: Int
    let lastDay: QuranTime?
}
