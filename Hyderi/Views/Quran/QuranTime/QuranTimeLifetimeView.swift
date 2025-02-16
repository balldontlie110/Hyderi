//
//  QuranTimeLifetimeView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/23/24.
//

import SwiftUI
import Charts

struct QuranTimeLifetimeView: View {
    @Environment(\.quranTimes) private var quranTimes
    
    var body: some View {
        VStack {
            dateRange
            
            chart
            
            Spacer()
            
            totalTime
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

extension QuranTimeLifetimeView {
    var dateRange: some View {
        Text(formattedDateRange())
            .font(.headline)
            .singleLine()
            .padding(10)
    }
    
    private func formattedDateRange() -> String {
        guard let start = quranTimes.first?.date, let lastWeek = quranTimes.last?.date, let end = Calendar.current.date(byAdding: .day, value: 6, to: lastWeek) else { return "" }
        
        switch (start.component(.month) == end.component(.month), start.component(.year) == end.component(.year)) {
        case (true, true):
            return "\(start.day()) - \(end.day()) \(end.month()) \(end.year())"
        case (false, true):
            return "\(start.day()) \(start.month()) - \(end.day()) \(end.month()) \(end.year())"
        default:
            return "\(start.day()) \(start.month()) \(start.year()) - \(end.day()) \(end.month()) \(end.year())"
        }
    }
}

extension QuranTimeLifetimeView {
    @ViewBuilder
    var chart: some View {
        if let firstDate = weeks.first?.key, let lastDate = weeks.last?.key, let safeDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: firstDate) {
            Chart(weeks, id: \.key) { date, week in
                BarMark(x: .value("Date", date), y: .value("Time", time(for: week)))
            }
            .chartXScale(domain: firstDate...max(lastDate, safeDate))
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .weekOfYear)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(formatTime(from: value))
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private func time(for week: [QuranTime]) -> Int {
        week.reduce(0) { partialResult, day in
            partialResult + Int(day.time)
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
    
    private var weeks: [(key: Date, value: [QuranTime])] {
        Dictionary(grouping: quranTimes, by: { $0.date.startOfWeek() ?? Date() }).sorted(by: { $0.key < $1.key })
    }
}

extension QuranTimeLifetimeView {
    var totalTime: some View {
        Text(totalTimeString)
            .font(.system(.title3, weight: .semibold))
            .singleLine()
    }
    
    private var totalTimeString: String {
        let seconds = quranTimes.reduce(0) { partialResult, day in
            partialResult + Int(day.time)
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        
        return formatter.string(from: TimeInterval(seconds)) ?? ""
    }
}

#Preview {
    QuranTimeLifetimeView()
}
