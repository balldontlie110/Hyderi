//
//  QuranTimeStreakCalendarView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/23/24.
//

import SwiftUI
import CoreData

struct QuranTimeStreakCalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.quranTimes) private var quranTimes
    
    private let columns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            weekdayHeaders
            
            ForEach(0..<firstDay, id: \.self) { _ in
                Spacer()
            }
            
            ForEach(filledInDays) { day in
                DayCard(day: day)
            }
        }.padding(.horizontal, 10)
    }
    
    private var weekdayHeaders: some View {
        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
            Text(weekday.uppercased())
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var firstDay: Int {
        let weekday = (quranTimes.first?.date.component(.weekday) ?? 1) - 1
        
        return weekday
    }
    
    private var filledInDays: [QuranTime] {
        let quranTimeDates = quranTimes.map({ $0.date })
        
        guard let start = quranTimeDates.min(), let end = quranTimeDates.max(), let days = Calendar.current.dateComponents([.day], from: start, to: end).day else { return [] }
        
        let dates = stride(from: 0, through: days, by: 1).compactMap({ Calendar.current.date(byAdding: .day, value: $0, to: start) })
        
        var quranTimes: [QuranTime] = []
        
        for date in dates {
            if let day = self.quranTimes.first(where: { $0.date == date }) {
                quranTimes.append(day)
            } else {
                quranTimes.append(QuranTime(date: date, time: 0))
            }
        }
        
        return quranTimes
    }
    
    private struct DayCard: View {
        let day: QuranTime
        
        @State private var showTime: Bool = false
        
        var body: some View {
            Button {
                if day.time > 0 {
                    showTime.toggle()
                }
            } label: {
                Text(day.date.day())
                    .bold()
                    .foregroundStyle(foregroundColor)
                    .singleLine()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }.popover(isPresented: $showTime) {
                Text(time)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .presentationCompactAdaptation(.popover)
            }
        }
        
        private var foregroundColor: Color {
            day.time > .minimumStreak ? Color.black : Color.primary
        }
        
        @ViewBuilder
        private var background: some View {
            if day.time > .minimumStreak {
                Color.streak
            } else if day.time > 0 {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.streak, lineWidth: 1)
            } else {
                Color(.secondarySystemBackground)
            }
        }
        
        private var time: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            
            return formatter.string(from: TimeInterval(day.time)) ?? ""
        }
    }
}

#Preview {
    QuranTimeStreakCalendarView()
}
