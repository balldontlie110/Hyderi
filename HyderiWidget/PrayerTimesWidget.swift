//
//  HyderiWidget.swift
//  HyderiWidget
//
//  Created by Ali Earp on 12/14/24.
//

import WidgetKit
import SwiftUI

struct PrayerTimesProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerTimesEntry {
        PrayerTimesEntry(date: Date(), prayerTimes: [:], islamicDay: 0, islamicMonth: .none, islamicYear: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PrayerTimesEntry) -> ()) {
        fetchPrayerTimesAndIslamicDate { prayerTimes, islamicDay, islamicMonth, islamicYear in
            let entry = PrayerTimesEntry(date: Date(), prayerTimes, islamicDay, islamicMonth, islamicYear)
            
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        fetchPrayerTimesAndIslamicDate { prayerTimes, islamicDay, islamicMonth, islamicYear in
            let entry = PrayerTimesEntry(date: Date(), prayerTimes, islamicDay, islamicMonth, islamicYear)
            
            guard let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()), let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())?.startOfDay() else { return }
            
            let timeline = Timeline(entries: [entry], policy: .after(min(nextHour, tomorrow)))
            completion(timeline)
        }
    }
    
    private func fetchPrayerTimesAndIslamicDate(completion: @escaping ([Prayer : Date], Int, IslamicMonth, Int) -> Void) {
        PrayerTimeModel.fetchPrayerTimesToday { prayerTimesToday in
            guard let islamicDate = CalendarModel.islamicDate(from: Date()) else { return }
            
            completion(prayerTimesToday, islamicDate.islamicDay, islamicDate.islamicMonth, islamicDate.islamicYear)
        }
    }
}

struct PrayerTimesWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: PrayerTimesEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SystemSmall(entry: entry)
        case .systemMedium:
            SystemMedium(entry: entry, nextPrayerTime: nextPrayerTime)
        case .accessoryCircular:
            AccessoryCircular(entry: entry, previousPrayerTime: previousPrayerTime, nextPrayerTime: nextPrayerTime)
        case .accessoryRectangular:
            AccessoryRectangular(entry: entry, nextPrayerTime: nextPrayerTime)
        default:
            EmptyView()
        }
    }
    
    private struct SystemSmall: View {
        let entry: PrayerTimesEntry
        
        let columns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 2)
        
        var body: some View {
            VStack {
                islamicDate
                
                Spacer()
                
                LazyVGrid(columns: columns, alignment: .center, spacing: 2.5) {
                    ForEach(prayerTimes, id: \.key) { prayer, time in
                        Text(prayer.formatted)
                            .foregroundStyle(Color.secondary)
                        
                        Text(time.time())
                            .fontWeight(.bold)
                    }
                }
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
        }
        
        private var prayerTimes: [(key: Prayer, value: Date)] {
            entry.prayerTimes.filter({ $0.key.isWidget }).sorted(by: { $0.value < $1.value })
        }
        
        private var islamicDate: some View {
            Text("\(entry.islamicDay) \(entry.islamicMonth.formatted) \(entry.islamicYear)")
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
    
    private struct SystemMedium: View {
        let entry: PrayerTimesEntry
        
        let columns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 5)
        
        let nextPrayerTime: (prayer: Prayer, time: Date)?
        
        var body: some View {
            VStack {
                header
                
                Spacer()
                
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(prayerTimes, id: \.key) { prayer, time in
                        VStack(spacing: 5) {
                            Text(prayer.formatted)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            
                            Text(time.time())
                                .fontWeight(.bold)
                        }
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                Spacer()
            }
        }
        
        private var prayerTimes: [(key: Prayer, value: Date)] {
            entry.prayerTimes.filter({ $0.key.isWidget }).sorted(by: { $0.value < $1.value })
        }
        
        private var header: some View {
            HStack(spacing: 10) {
                hyderiLogo
                
                nextPrayerTimeText
                
                Spacer()
                
                islamicDate
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        
        private var hyderiLogo: some View {
            Image("hyderi")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .clipShape(RoundedRectangle(cornerRadius: 7.5))
        }
        
        @ViewBuilder
        private var nextPrayerTimeText: some View {
            if let nextPrayerTime {
                Text("\(nextPrayerTime.prayer.formatted) \(nextPrayerTime.time.timeSinceNow(unitsStyle: .short))")
                    .font(.headline)
            }
        }
        
        @ViewBuilder
        private var islamicDate: some View {
            Text(entry.islamicMonth.formatted)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
            
            Text(String(entry.islamicDay))
                .font(.title)
                .fontWeight(.heavy)
        }
    }
    
    private struct AccessoryCircular: View {
        let entry: PrayerTimesEntry
        
        let previousPrayerTime: (prayer: Prayer, time: Date)?
        let nextPrayerTime: (prayer: Prayer, time: Date)?
        
        var body: some View {
            if let previousPrayerTime, let nextPrayerTime {
                let totalTimeInterval = nextPrayerTime.time.timeIntervalSince(previousPrayerTime.time)
                let remainingTimeInterval = nextPrayerTime.time.timeIntervalSince(Date())
                
                let percentageTimeInterval = min(remainingTimeInterval / totalTimeInterval, 1)
                
                Gauge(value: percentageTimeInterval) {
                    VStack {
                        Text(nextPrayerTime.prayer.nextPrayer)
                        
                        if let timeUntilNextPrayer = nextPrayerTime.time.shortTimeSinceNow() {
                            Text(timeUntilNextPrayer)
                        }
                    }
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .multilineTextAlignment(.center)
            }
        }
    }
    
    private struct AccessoryRectangular: View {
        let entry: PrayerTimesEntry
        
        let nextPrayerTime: (prayer: Prayer, time: Date)?
        
        var body: some View {
            if let nextPrayerTime {
                LazyVStack(alignment: .leading) {
                    Text("\(nextPrayerTime.prayer.formatted) upcoming")
                        .font(.headline)
                    
                    Text(nextPrayerTime.time.timeSinceNow(unitsStyle: .full))
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(nextPrayerTime.prayer.emoji)  \(nextPrayerTime.time.time())")
                }
            }
        }
    }
    
    private var prayerTimes: [(key: Prayer, value: Date)] {
        return entry.prayerTimes.sorted(by: { $0.key < $1.key })
    }
    
    private var previousPrayerTime: (prayer: Prayer, time: Date)? {
        return prayerTimes.last(where: { $0.value.isBefore(date: Date()) }) ?? shift(prayerTimes.last, by: .day, value: -1) as (Prayer, Date)?
    }
    
    private var nextPrayerTime: (prayer: Prayer, time: Date)? {
        prayerTimes.first(where: { $0.value.isAfter(date: Date()) }) ?? shift(prayerTimes.first, by: .day, value: 1) as (Prayer, Date)?
    }
    
    private func shift(_ prayerTime: (key: Prayer, value: Date)?, by component: Calendar.Component, value: Int) -> (key: Prayer, value: Date)? {
        guard let prayerTime else { return nil }
        
        guard let shiftedDate = Calendar.current.date(byAdding: component, value: value, to: prayerTime.value) else { return nil }
        
        return (prayerTime.key, shiftedDate)
    }
}

struct PrayerTimesWidget: Widget {
    let kind: String = "PrayerTimesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimesProvider()) { entry in
            PrayerTimesWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Prayer Times")
        .description("Easily see prayer times at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

#Preview(as: .systemSmall) {
    PrayerTimesWidget()
} timeline: {
    PrayerTimesEntry(date: Date(), prayerTimes: [:], islamicDay: 0, islamicMonth: .none, islamicYear: 0)
}
