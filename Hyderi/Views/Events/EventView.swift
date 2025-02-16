//
//  EventView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/8/24.
//

import SwiftUI
import iCalendarParser
import CoreLocation
import MapKit

struct EventView: View {
    let event: ICEvent
    
    @Binding var notifyingEventTime: EventTime
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                header
                
                Divider()
                
                description
                
                link
                
                Divider()
                
                otherInfo
            }.padding(10)
        }
    }
    
    private var header: some View {
        HStack(alignment: .top, spacing: 20) {
            if let summary = event.summary {
                Text(summary)
                    .font(.system(.title2, weight: .bold))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            notificationButton
        }
    }
    
    @ViewBuilder
    private var notificationButton: some View {
        if let start = event.date(), start > Date() {
            Menu {
                ForEach(EventTime.allCases(notifyingEventTime), id: \.rawValue) { eventTime in
                    Button {
                        EventModel.scheduleNotification(for: event, eventTime: eventTime) { eventTime in
                            notifyingEventTime = eventTime
                        }
                    } label: {
                        HStack {
                            Text(eventTime.menuString)
                            
                            Spacer()
                            
                            if eventTime == notifyingEventTime {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: notifyingEventTime == .none ? "bell" : "bell.fill")
                    .font(.system(size: 20))
            }
        }
    }
    
    @ViewBuilder
    private var description: some View {
        if let description = event.description?.cleaned() {
            Text(description)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    private var link: some View {
        if let url = event.url {
            Link(destination: url) {
                Text(url.absoluteString)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private var otherInfo: some View {
        GeometryReader { proxy in
            HStack(alignment: .top) {
                location
                
                Spacer()
                
                time
                    .frame(maxWidth: proxy.size.width / 3)
            }.fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    private var location: some View {
        if let location = event.location?.cleaned() {
            Button {
                openLocation(location)
            } label: {
                Text(location)
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.leading)
                    .underline()
            }
        }
    }
    
    private func openLocation(_ location: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first else { return }
            
            let destination = MKMapItem(placemark: MKPlacemark(placemark: placemark))
            
            destination.openInMaps()
        }
    }
    
    @ViewBuilder
    private var time: some View {
        Text(formattedTimeRange)
            .font(.callout)
            .foregroundStyle(Color.secondary)
            .multilineTextAlignment(.trailing)
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

#Preview {
    EventView(event: ICEvent(), notifyingEventTime: .constant(.none))
}
