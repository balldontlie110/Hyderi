//
//  IslamicDateWidget.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import WidgetKit
import SwiftUI

struct IslamicDateProvider: TimelineProvider {
    func placeholder(in context: Context) -> IslamicDateEntry {
        IslamicDateEntry(date: Date(), islamicDay: 0, islamicMonth: .none)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (IslamicDateEntry) -> ()) {
        guard let islamicDate = CalendarModel.islamicDate(from: Date()) else { return }
        
        let entry = IslamicDateEntry(date: Date(), islamicDate.islamicDay, islamicDate.islamicMonth)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let islamicDate = CalendarModel.islamicDate(from: Date()) else { return }
        
        let entry = IslamicDateEntry(date: Date(), islamicDate.islamicDay, islamicDate.islamicMonth)
        
        guard let updateDate = Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfDay()) else { return }
        
        let timeline = Timeline(entries: [entry], policy: .after(updateDate))
        completion(timeline)
    }
}

struct IslamicDateWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: IslamicDateEntry
    
    var body: some View {
        switch widgetFamily {
        case .accessoryInline:
            AccessoryInline(entry: entry)
        default:
            EmptyView()
        }
    }
    
    private struct AccessoryInline: View {
        let entry: IslamicDateEntry
        
        var body: some View {
            Text("🌙  \(entry.islamicDay) \(entry.islamicMonth.formatted)")
        }
    }
}

struct IslamicDateWidget: Widget {
    let kind: String = "IslamicDateWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IslamicDateProvider()) { entry in
            IslamicDateWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Islamic Date")
        .description("Current Islamic day and month right on your lock screen.")
        .supportedFamilies([.accessoryInline])
    }
}

#Preview(as: .systemSmall) {
    IslamicDateWidget()
} timeline: {
    IslamicDateEntry(date: Date(), islamicDay: 0, islamicMonth: .none)
}
