//
//  QuranTimeWeekViewChart.swift
//  Hyderi
//
//  Created by Ali Earp on 12/25/24.
//

import SwiftUI
import Charts

struct QuranTimeWeekViewChart: View {
    let selectedWeek: Date?
    let endOfSelectedWeek: Date?
    
    let week: [QuranTime]
    
    let dayMarksStride: Int
    let desiredTimeMarks: Int?
    
    init(selectedWeek: Date?, endOfSelectedWeek: Date?, week: [QuranTime]) {
        self.selectedWeek = selectedWeek
        self.endOfSelectedWeek = endOfSelectedWeek
        
        self.week = week
        
        self.dayMarksStride = 1
        self.desiredTimeMarks = nil
    }
    
    init(_ selectedWeek: Date?, _ endOfSelectedWeek: Date?, _ week: [QuranTime], _ dayMarksStride: Int = 1, _ desiredTimeMarks: Int? = nil) {
        self.selectedWeek = selectedWeek
        self.endOfSelectedWeek = endOfSelectedWeek
        
        self.week = week
        
        self.dayMarksStride = dayMarksStride
        self.desiredTimeMarks = desiredTimeMarks
    }
    
    var body: some View {
        if let selectedWeek, let endOfSelectedWeek {
            Chart(week) { day in
                BarMark(x: .value("Date", day.date), y: .value("Time", day.time))
            }
            .chartXScale(domain: selectedWeek...endOfSelectedWeek)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day, count: dayMarksStride)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: desiredTimeMarks)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(formatTime(from: value))
                }
            }
        }
    }
    
    private func formatTime(from value: AxisValue) -> String {
        guard let seconds = value.as(Int.self) else { return "" }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .dropAll
        
        let time = formatter.string(from: TimeInterval(seconds)) ?? ""
        
        if seconds < 60 {
            return time + "s"
        } else if seconds < 3600 {
            return time + (seconds % 60 == 0 ? "m" : "s")
        } else {
            return time + (seconds % 3600 == 0 ? "h" : (seconds % 60 == 0 ? "m" : "s"))
        }
    }
}

#Preview {
    QuranTimeWeekViewChart(selectedWeek: nil, endOfSelectedWeek: nil, week: [])
}
