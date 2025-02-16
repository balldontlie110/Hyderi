//
//  StreakWidget.swift
//  Hyderi
//
//  Created by Ali Earp on 12/24/24.
//

import WidgetKit
import SwiftUI
import CoreData

struct StreakProvider: TimelineProvider {
    private let viewContext: NSManagedObjectContext = CoreDataManager.shared.container.viewContext
    
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 0, lastDay: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> ()) {
        let streak = QuranTimeModel.updateStreak(quranTimes: quranTimes, refreshWidgets: false)
        let entry = StreakEntry(date: Date(), streak: streak, lastDay: quranTimes.last)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let streak = QuranTimeModel.updateStreak(quranTimes: quranTimes, refreshWidgets: false)
        let entry = StreakEntry(date: Date(), streak: streak, lastDay: quranTimes.last)
        
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

struct StreakWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: StreakEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SystemSmall(entry: entry)
        default:
            EmptyView()
        }
    }
    
    private struct SystemSmall: View {
        let entry: StreakEntry
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(streakColor.flame)
                
                Text(String(entry.streak))
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundStyle(streakColor.days)
            }
        }
        
        private var today: Bool {
            guard let lastDay = entry.lastDay else { return false }
            
            return Calendar.current.isDateInToday(lastDay.date)
        }
        
        private var streakColor: (flame: Color, days: Color) {
            if today, let lastDay = entry.lastDay, lastDay.time > .minimumStreak {
                return (Color.streak, Color.primary)
            }
            
            return (Color.secondary, Color.secondary)
        }
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Easily keep track of your current Quran streak.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: Date(), streak: 0, lastDay: nil)
}
