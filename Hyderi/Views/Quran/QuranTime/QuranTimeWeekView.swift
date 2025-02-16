//
//  QuranTimeWeekView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/23/24.
//

import SwiftUI

struct QuranTimeWeekView: View {
    @Environment(\.quranTimes) private var quranTimes
    
    @State private var selectedWeek: Date?
    
    var body: some View {
        VStack {
            weekSelector
            
            Spacer()
            
            QuranTimeWeekViewChart(selectedWeek: selectedWeek, endOfSelectedWeek: endOfSelectedWeek, week: week)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut, value: selectedWeek)
            
            Spacer()
            
            totalTime
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear {
            self.selectedWeek = weeks.last
        }
    }
    
    var week: [QuranTime] {
        guard let selectedWeek else { return [] }
        
        return quranTimes.filter({ Calendar.current.isDate($0.date, equalTo: selectedWeek, toGranularity: .weekOfYear) })
    }
    
    var endOfSelectedWeek: Date? {
        guard let selectedWeek else { return nil }
        
        return Calendar.current.date(byAdding: .day, value: 6, to: selectedWeek)
    }
}

extension QuranTimeWeekView {
    @ViewBuilder
    var weekSelector: some View {
        if let selectedWeek {
            HStack {
                lastWeekButton(before: selectedWeek)
                
                Spacer()
                
                Text(formattedWeekRange(from: selectedWeek))
                    .font(.headline)
                
                Spacer()
                
                nextWeekButton(after: selectedWeek)
            }
            .singleLine()
            .padding(.bottom, 5)
        }
    }
    
    private func lastWeekButton(before selectedWeek: Date) -> some View {
        Button {
            self.selectedWeek = weeks.last(where: { $0 < selectedWeek })
        } label: {
            Image(systemName: "chevron.left")
                .fontWeight(.semibold)
        }.disabled(!weeks.contains(where: { $0 < selectedWeek }))
    }
    
    private func nextWeekButton(after selectedWeek: Date) -> some View {
        Button {
            self.selectedWeek = weeks.first(where: { $0 > selectedWeek })
        } label: {
            Image(systemName: "chevron.right")
                .fontWeight(.semibold)
        }.disabled(!weeks.contains(where: { $0 > selectedWeek }))
    }
    
    private func formattedWeekRange(from start: Date) -> String {
        guard let end = Calendar.current.date(byAdding: .day, value: 6, to: start) else { return "" }
        
        switch (start.component(.month) == end.component(.month), start.component(.year) == end.component(.year)) {
        case (true, true):
            return "\(start.day()) - \(end.day()) \(end.month()) \(end.year())"
        case (false, true):
            return "\(start.day()) \(start.month()) - \(end.day()) \(end.month()) \(end.year())"
        default:
            return "\(start.day()) \(start.month()) \(start.year()) - \(end.day()) \(end.month()) \(end.year())"
        }
    }
    
    private var weeks: [Date] {
        Set(quranTimes.compactMap({ $0.date.startOfWeek() })).sorted()
    }
}

extension QuranTimeWeekView {
    var totalTime: some View {
        Text(totalTimeString)
            .font(.system(.title3, weight: .semibold))
            .singleLine()
    }
    
    private var totalTimeString: String {
        let seconds = week.reduce(0) { partialResult, day in
            partialResult + Int(day.time)
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        
        return formatter.string(from: TimeInterval(seconds)) ?? ""
    }
}

#Preview {
    QuranTimeWeekView()
}
