//
//  HyderiWidgetBundle.swift
//  HyderiWidget
//
//  Created by Ali Earp on 12/14/24.
//

import WidgetKit
import SwiftUI

@main
struct HyderiWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrayerTimesWidget()
        IslamicDateWidget()
        StreakWidget()
        QuranTimeWidget()
    }
}
