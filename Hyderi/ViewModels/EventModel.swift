//
//  EventModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/7/24.
//

import SwiftUI
import iCalendarParser

class EventModel: ObservableObject {
    @Published var events: [ICEvent] = []
    
    @Published var loading: Bool = true
    
    init() {
        fetchEvents()
    }
    
    private func fetchEvents() {
        guard let url = URL(string: "https://hyderi.org.uk/all-events/list/?hide_subsequent_recurrences=1&ical=1") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data, let content = String(data: data, encoding: .utf8) else { return }
            
            let parser = ICParser()
            let calendar: ICalendar? = parser.calendar(from: content)
            
            guard let calendar else { return }
            
            DispatchQueue.main.async {
                self.events = calendar.events
                
                self.loading = false
            }
        }.resume()
    }
    
    static func location(from location: String?) -> String? {
        guard let rootLocation = location?.split(separator: ",").first else { return nil }
        
        return String(rootLocation).cleaned()
    }
}

extension ICEvent: @retroactive Identifiable {
    public var id: String {
        return self.uid
    }
}
