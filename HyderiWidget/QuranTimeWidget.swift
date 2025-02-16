//
//  QuranTimeWidget.swift
//  Hyderi
//
//  Created by Ali Earp on 12/25/24.
//

import WidgetKit
import SwiftUI
import CoreData

struct QuranTimeProvider: TimelineProvider {
    private let viewContext: NSManagedObjectContext = CoreDataManager.shared.container.viewContext
    
    func placeholder(in context: Context) -> QuranTimeEntry {
        QuranTimeEntry(date: Date(), quranTimes: [], islamicDay: 0, islamicMonth: .none, islamicYear: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuranTimeEntry) -> ()) {
        guard let islamicDate = CalendarModel.islamicDate(from: Date()) else { return }
        
        let entry = QuranTimeEntry(date: Date(), quranTimes, islamicDate.islamicDay, islamicDate.islamicMonth, islamicDate.islamicYear)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let islamicDate = CalendarModel.islamicDate(from: Date()) else { return }
        
        let entry = QuranTimeEntry(date: Date(), quranTimes, islamicDate.islamicDay, islamicDate.islamicMonth, islamicDate.islamicYear)
        
        guard let updateDate = Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfDay()) else { return }
        
        let timeline = Timeline(entries: [entry], policy: .after(updateDate))
        completion(timeline)
    }
    
    private var quranTimes: [QuranTime] {
        let fetchRequest: NSFetchRequest<QuranTime> = NSFetchRequest(entityName: QuranTime.description())
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \QuranTime.date, ascending: true)]
        
        do {
            let quranTimes = try viewContext.fetch(fetchRequest)
            
            return quranTimes
        } catch {
            print(error)
        }
        
        return []
    }
}

struct QuranTimeWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: QuranTimeEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            System(selectedWeek, endOfSelectedWeek, week, header, dayMarksStride: 2, desiredTimeMarks: 3)
        case .systemMedium:
            System(selectedWeek, endOfSelectedWeek, week, header, desiredTimeMarks: 3)
        case .systemLarge:
            System(selectedWeek, endOfSelectedWeek, week, header)
        default:
            EmptyView()
        }
    }
    
    private struct System: View {
        let selectedWeek: Date?
        let endOfSelectedWeek: Date?
        
        let week: [QuranTime]
        
        let header: any View
        
        let dayMarksStride: Int
        let desiredTimeMarks: Int?
        
        init(_ selectedWeek: Date?, _ endOfSelectedWeek: Date?, _ week: [QuranTime], _ header: any View, dayMarksStride: Int = 1, desiredTimeMarks: Int? = nil) {
            self.selectedWeek = selectedWeek
            self.endOfSelectedWeek = endOfSelectedWeek
            
            self.week = week
            
            self.header = header
            
            self.dayMarksStride = dayMarksStride
            self.desiredTimeMarks = desiredTimeMarks
        }
        
        var body: some View {
            VStack(spacing: 5) {
                AnyView(header)
                
                QuranTimeWeekViewChart(selectedWeek, endOfSelectedWeek, week, dayMarksStride, desiredTimeMarks)
            }
        }
    }
}

extension QuranTimeWidgetEntryView {
    private var weeks: [Date] {
        Set(entry.quranTimes.compactMap({ $0.date.startOfWeek() })).sorted()
    }
    
    var selectedWeek: Date? {
        weeks.last
    }
    
    var endOfSelectedWeek: Date? {
        guard let selectedWeek else { return nil }
        
        return Calendar.current.date(byAdding: .day, value: 6, to: selectedWeek)
    }
    
    var week: [QuranTime] {
        guard let selectedWeek else { return [] }
        
        return entry.quranTimes.filter({ Calendar.current.isDate($0.date, equalTo: selectedWeek, toGranularity: .weekOfYear) })
    }
}

extension QuranTimeWidgetEntryView {
    var header: some View {
        HStack(spacing: 10) {
            hyderiLogo
            
            totalTime
            
            Spacer()
            
            if widgetFamily != .systemSmall {
                islamicDate
            }
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
    private var totalTime: some View {
        if let totalTimeString {
            Text(totalTimeString)
                .font(.headline)
        }
    }
    
    private var totalTimeString: String? {
        let seconds = week.reduce(0) { partialResult, day in
            partialResult + Int(day.time)
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: TimeInterval(seconds)) ?? ""
    }
    
    @ViewBuilder
    private var islamicDate: some View {
        Text(entry.islamicMonth.formatted)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.secondary)
            .multilineTextAlignment(.trailing)
        
        Text(String(entry.islamicDay))
            .font(.title)
            .fontWeight(.heavy)
    }
}

struct QuranTimeWidget: Widget {
    let kind: String = "QuranTimeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuranTimeProvider()) { entry in
            QuranTimeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quran Time")
        .description("Keep track of how long you've spent reading Quran this week.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    QuranTimeWidget()
} timeline: {
    QuranTimeEntry(date: Date(), quranTimes: [], islamicDay: 0, islamicMonth: .none, islamicYear: 0)
}

