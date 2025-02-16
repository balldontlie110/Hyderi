//
//  EventsView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI
import iCalendarParser

struct EventsView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject private var eventModel: EventModel = EventModel()
    
    let date: Date?
    
    init(date: Date? = nil) {
        self.date = date
    }
    
    var body: some View {
        if eventModel.loading && date == nil {
            ProgressView()
                .navigationTitle("Events")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            eventsScrollView
                .if(date == nil) { view in
                    view
                        .navigationTitle("Events")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                }
        }
    }
    
    private var events: [(key: Date, value: [ICEvent])] {
        if let date {
            let events = eventModel.events.filter { event in
                guard let start = event.date(), let end = event.date(start: false), let days = Calendar.current.dateComponents([.day], from: start, to: end).day else { return false }
                
                let range = stride(from: 0, through: days, by: 1).compactMap({ Calendar.current.date(byAdding: .day, value: $0, to: start)?.startOfDay() })
                
                return range.contains(date)
            }
            
            return Dictionary(grouping: events, by: { $0.date()?.startOfMonth() ?? Date() }).sorted(by: { $0.key < $1.key })
        }
        
        return Dictionary(grouping: eventModel.events, by: { $0.date()?.startOfMonth() ?? Date() }).sorted(by: { $0.key < $1.key })
    }
    
    var eventsScrollView: some View {
        ScrollView {
            LazyVStack {
                ForEach(events, id: \.key) { date, events in
                    LazyVStack(alignment: .leading, spacing: 10) {
                        if self.date == nil {
                            Text(date.month())
                                .font(.system(.title, weight: .bold))
                                .padding(.horizontal, 10)
                        }
                        
                        ForEach(events) { event in
                            Event(event: event)
                        }
                    }.padding(.bottom)
                }
            }
            .padding(date == nil ? 10 : 0)
            .safeAreaPadding(.bottom, audioPlayer.player != nil && date == nil ? 75 : 0)
        }
    }
    
    private struct Event: View {
        let event: ICEvent
        
        @State private var notifyingEventTime: EventTime = .none
        
        var body: some View {
            NavigationLink {
                EventView(event: event, notifyingEventTime: $notifyingEventTime)
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    dateSection
                    
                    infoSection
                }
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
                .secondaryRoundedBackground(cornerRadius: 5)
            }.task {
                notifyingEventTime = await EventModel.isNotifying(event: event)
            }
        }
        
        private var dateSection: some View {
            VStack {
                if let weekday = event.weekday() {
                    Text(weekday)
                }
                
                if let day = event.day() {
                    Text(String(day))
                        .font(.system(.title, weight: .bold))
                }
                
                if let month = event.month() {
                    Text(month)
                        .font(.system(.caption, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }.frame(width: 80)
        }
        
        private var infoSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(formattedTimeRange)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    
                    Spacer()
                    
                    if notifyingEventTime != .none {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.primary)
                    }
                }
                
                if let summary = event.summary {
                    Text(summary)
                        .lineLimit(nil)
                }
                
                if let location = EventModel.location(from: event.location) {
                    Text(location)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }.multilineTextAlignment(.leading)
        }
        
        private var formattedTimeRange: String {
            guard let start = event.date(), let end = event.date(start: false) else { return "" }
            
            if start.component(.day) == end.component(.day) && start.component(.month) == end.component(.month) {
                return "\(start.month()) \(start.day()) @ \(start.time()) - \(end.time())"
            } else {
                return "\(start.month()) \(start.day()) @ \(start.time()) - \(end.month()) \(end.day()) \(end.time())"
            }
        }
    }
}

#Preview {
    EventsView()
}
