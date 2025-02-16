//
//  PrayerTimesView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/8/24.
//

import SwiftUI

struct PrayerTimesView: View {
    let prayerTimes: [Prayer : Date]
    
    let columns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(sortedPrayerTimes, id: \.key) { prayer, time in
                VStack(spacing: 5) {
                    Text(prayer.formatted)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    
                    Text(time.time())
                        .font(.system(.subheadline, weight: .bold))
                }
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .frame(height: 50)
        .padding(10)
    }
    
    private var sortedPrayerTimes: [(key: Prayer, value: Date)] {
        return prayerTimes.sorted(by: { $0.key < $1.key })
    }
}

#Preview {
    PrayerTimesView(prayerTimes: [:])
}
