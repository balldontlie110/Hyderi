//
//  CalendarView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject var calendarModel: CalendarModel
    @StateObject var prayerTimeModel: PrayerTimeModel
    
    @State private var selectedMonth: Date? = Date().startOfMonth()
    @State private var selectedDay: Date? = Date().startOfDay()
    
    private let columns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                monthSelector
                
                calendar
                
                dateAndPrayerTimes
                
                EventsView(date: selectedDay)
                
                importantDates
            }
            .padding(10)
            .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }
}

extension CalendarView {
    @ViewBuilder
    var monthSelector: some View {
        if let selectedMonth {
            HStack {
                lastMonthButton(before: selectedMonth)
                
                Spacer()
                
                Text(month(from: selectedMonth))
                    .font(.headline)
                
                Spacer()
                
                nextMonthButton(after: selectedMonth)
            }
            .singleLine()
            .padding(.bottom, 5)
        }
    }
    
    private func lastMonthButton(before selectedMonth: Date) -> some View {
        Button {
            self.selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)
            
            guard let selectedDay else { return }
            
            self.selectedDay = Calendar.current.date(byAdding: .month, value: -1, to: selectedDay)
        } label: {
            Image(systemName: "chevron.left")
                .fontWeight(.semibold)
        }
    }
    
    private func nextMonthButton(after selectedMonth: Date) -> some View {
        Button {
            self.selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)
            
            guard let selectedDay else { return }
            
            self.selectedDay = Calendar.current.date(byAdding: .month, value: 1, to: selectedDay)
        } label: {
            Image(systemName: "chevron.right")
                .fontWeight(.semibold)
        }
    }
    
    private func month(from selectedMonth: Date) -> String {
        "\(selectedMonth.month()) \(selectedMonth.year())"
    }
}

extension CalendarView {
    var calendar: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            weekdayHeaders
            
            ForEach(0..<firstDay, id: \.self) { _ in
                Spacer()
            }
            
            ForEach(days, id: \.self) { day in
                DayCard(day: day, selectedDay: $selectedDay)
            }
        }.padding(.vertical, 10)
    }
    
    private var weekdayHeaders: some View {
        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
            Text(weekday.uppercased())
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var firstDay: Int {
        let weekday = (selectedMonth?.component(.weekday) ?? 1) - 1
        
        return weekday
    }
    
    var days: [Date] {
        guard let selectedMonth, let daysRange = Calendar.current.range(of: .day, in: .month, for: selectedMonth) else { return [] }
        
        return daysRange.compactMap({ Calendar.current.date(byAdding: .day, value: $0 - 1, to: selectedMonth) })
    }
    
    private struct DayCard: View {
        let day: Date
        
        @Binding var selectedDay: Date?
        
        var body: some View {
            Button {
                selectedDay = day
            } label: {
                VStack(spacing: 5) {
                    if let islamicDay = CalendarModel.islamicDate(from: day)?.islamicDay {
                        Text(String(islamicDay))
                            .font(.caption)
                            .foregroundStyle(secondaryColor)
                    }
                    
                    Text(day.day())
                        .bold()
                        .foregroundStyle(foregroundColor)
                }
                .singleLine()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        
        private var foregroundColor: Color {
            if Calendar.current.isDateInToday(day) {
                return Color(.systemBackground)
            }
            
            return Color.primary
        }
        
        private var secondaryColor: Color {
            if Calendar.current.isDateInToday(day) {
                return Color(.systemBackground)
            }
            
            return Color.secondary
        }
        
        private var background: Color {
            if Calendar.current.isDateInToday(day) {
                return Color.accentColor
            }
            
            if day == selectedDay {
                return Color.accentColor.opacity(0.2)
            }
            
            return Color(.systemBackground)
        }
    }
}

extension CalendarView {
    @ViewBuilder
    var dateAndPrayerTimes: some View {
        if let selectedDay {
            date(selectedDay)
            
            prayerTimes(on: selectedDay)
        }
    }
    
    @ViewBuilder
    private func date(_ date: Date) -> some View {
        if let islamicSelectedDay = CalendarModel.islamicDate(from: date) {
            DateSection(islamicDate: islamicSelectedDay, date: date)
        }
    }
    
    @ViewBuilder
    private func prayerTimes(on date: Date) -> some View {
        if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            PrayerTimesView(prayerTimes: PrayerTimeModel.prayerTimes(on: date, from: prayerTimeModel.prayerTimes))
        }
    }
}

extension CalendarView {
    var importantDates: some View {
        ForEach(importantDatesInMonth) { importantDate in
            ImportantDateCard(importantDate: importantDate)
        }
    }
    
    private struct ImportantDateCard: View {
        let importantDate: ImportantDate
        
        var body: some View {
            HStack(alignment: .top, spacing: 10) {
                info
                
                Spacer()
                
                date
            }
            .padding(10)
            .secondaryRoundedBackground(cornerRadius: 5)
        }
        
        private var info: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(importantDate.title)
                    .font(.system(.callout, weight: .semibold))
                
                if let subtitle = importantDate.subtitle {
                    Text(subtitle)
                        .foregroundStyle(Color.secondary)
                        .font(.caption)
                }
            }.multilineTextAlignment(.leading)
        }
        
        private var date: some View {
            VStack(alignment: .trailing, spacing: 5) {
                if let islamicMonth = IslamicMonth(monthNumber: importantDate.month) {
                    Text("\(importantDate.day) \(islamicMonth.formatted)")
                }
                
                if let year = importantDate.year, let yearType = importantDate.yearType {
                    Text("\(year) \(yearType)")
                }
            }
            .font(.subheadline)
            .multilineTextAlignment(.trailing)
        }
    }
    
    private var importantDatesInMonth: [ImportantDate] {
        let islamicDates = days.compactMap({ ($0, CalendarModel.islamicDate(from: $0)) })
        
        let importantDates = calendarModel.importantDates.compactMap { importantDate in
            if let date = islamicDates.first(where: { date, islamicDate in
                importantDate.month == islamicDate?.islamicMonth.number && importantDate.day == islamicDate?.islamicDay
            })?.0 {
                return (date, importantDate)
            }
            
            return nil
        }
        
        return importantDates.sorted(by: { $0.0 < $1.0 }).map({ $0.1 })
    }
}

#Preview {
    CalendarView(calendarModel: CalendarModel(), prayerTimeModel: PrayerTimeModel())
}
