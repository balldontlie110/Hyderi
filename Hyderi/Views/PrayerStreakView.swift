//
//  PrayerStreakView.swift
//  Hyderi
//
//  Created by Ali Earp on 1/21/25.
//

import SwiftUI
import LocalAuthentication

struct PrayerStreakView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PrayerDay.date, ascending: true)], animation: .default)
    private var prayerDays: FetchedResults<PrayerDay>
    
    @State private var authenticated: Bool = false
    
    let columns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        if authenticated {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(prayerDays) { prayerDay in
                        Text(prayerDay.date.simpleDate())
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        
                        ForEach(prayerDay.prayers, id: \.key) { prayer, prayed in
                            VStack(spacing: 10) {
                                Text(prayer)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                
                                Image(systemName: prayed ? "checkmark.circle" : "xmark.circle")
                                    .foregroundStyle(prayed ? Color.green : Color.red)
                            }
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    }
                }.multilineTextAlignment(.center)
            }
        } else {
            authentication
        }
    }
}

extension PrayerStreakView {
    var authentication: some View {
        VStack(spacing: 15) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.secondary)
            
            Text("Use Face ID to View Your Prayer Streak Information")
                .font(.system(.title3, weight: .bold))
            
            Button {
                authenticate()
            } label: {
                Text("View Information")
                    .font(.callout)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        AuthenticationModel.authenticate(withReason: "To make sure it's really you when accessing your Prayer Streak information.") { success in
            authenticated = success
        }
    }
}

#Preview {
    PrayerStreakView()
}
